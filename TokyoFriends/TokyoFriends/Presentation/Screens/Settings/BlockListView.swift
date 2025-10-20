import SwiftUI

/// ブロックリスト画面
/// デザイン定義: 0.5_デザイン定義.md - 安全機能
struct BlockListView: View {

    @Bindable var viewModel: BlockListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "読み込み中...")
                } else if let error = viewModel.error {
                    ErrorView(
                        error: error,
                        retryAction: {
                            Task {
                                await viewModel.loadBlockedUsers()
                            }
                        }
                    )
                } else if viewModel.blockedUsers.isEmpty {
                    emptyState
                } else {
                    blockedUserList
                }
            }
            .navigationTitle("ブロックリスト")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                title: "ブロックを解除しますか？",
                message: "ブロックを解除すると、このユーザーが再びカードに表示されるようになります。",
                confirmTitle: "解除",
                confirmRole: nil,
                isPresented: $viewModel.showUnblockConfirmation,
                onConfirm: {
                    Task {
                        await viewModel.unblockUser()
                    }
                }
            )
            .task {
                await viewModel.loadBlockedUsers()
            }
        }
    }

    // MARK: - Blocked User List

    private var blockedUserList: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                ForEach(viewModel.blockedUsers) { user in
                    BlockedUserRow(
                        user: user,
                        onUnblock: {
                            viewModel.confirmUnblock(user)
                        }
                    )
                }
            }
            .padding(Spacing.l)
        }
        .background(ColorTokens.bgBase)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "checkmark.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.accentSuccess)

            VStack(spacing: Spacing.s) {
                Text("ブロックしているユーザーはいません")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("安全にアプリをご利用いただいています")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.l)
        .background(ColorTokens.bgBase)
    }
}

// MARK: - Blocked User Row

struct BlockedUserRow: View {
    let user: User
    let onUnblock: () -> Void

    var body: some View {
        HStack(spacing: Spacing.m) {
            // アバター
            Circle()
                .fill(ColorTokens.bgSection)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill.xmark")
                        .foregroundColor(ColorTokens.textTertiary)
                )

            // ユーザー情報
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("ユーザーID: \(user.id.uuidString.prefix(8))")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("ブロック日: \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textSecondary)
            }

            Spacer()

            // ブロック解除ボタン
            Button(action: onUnblock) {
                Text("解除")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.accentPrimary)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.xs)
                    .background(ColorTokens.accentPrimary.opacity(0.1))
                    .cornerRadius(CornerRadius.chip)
            }
        }
        .padding(Spacing.m)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
    }
}

// MARK: - ViewModel

@Observable
final class BlockListViewModel {
    var blockedUsers: [User] = []
    var isLoading = false
    var error: Error?
    var showUnblockConfirmation = false

    private var userToUnblock: User?
    private let currentUserId: UUID
    private let userRepository: UserRepository

    init(
        currentUserId: UUID,
        userRepository: UserRepository = RepositoryProvider.shared.userRepository
    ) {
        self.currentUserId = currentUserId
        self.userRepository = userRepository
    }

    @MainActor
    func loadBlockedUsers() async {
        isLoading = true
        error = nil

        do {
            blockedUsers = try await userRepository.fetchBlockedUsers(userId: currentUserId).compactMap { blockedUserId in
                // In a real app, we would fetch full user profiles
                // For mock, just return User objects
                MockData.users.first(where: { $0.id == blockedUserId })
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func confirmUnblock(_ user: User) {
        userToUnblock = user
        showUnblockConfirmation = true
    }

    @MainActor
    func unblockUser() async {
        guard let user = userToUnblock else { return }

        do {
            try await userRepository.unblockUser(userId: currentUserId, blockedUserId: user.id)
            blockedUsers.removeAll { $0.id == user.id }
            userToUnblock = nil
        } catch {
            self.error = error
        }
    }
}

// MARK: - Preview Factory

extension BlockListViewModel {
    static func make(currentUserId: UUID) -> BlockListViewModel {
        return BlockListViewModel(currentUserId: currentUserId)
    }
}

// MARK: - Preview

#if DEBUG
struct BlockListView_Previews: PreviewProvider {
    static var previews: some View {
        BlockListView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Block List View")
    }
}
#endif
