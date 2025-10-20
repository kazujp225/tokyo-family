import SwiftUI

/// アカウント詳細画面
/// デザイン定義: 0.5_デザイン定義.md - 設定画面
struct AccountDetailView: View {

    @Bindable var viewModel: AccountDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // アカウント情報セクション
                Section {
                    HStack {
                        Text("ユーザーID")
                        Spacer()
                        Text(viewModel.user.id.uuidString.prefix(8) + "...")
                            .foregroundColor(ColorTokens.textSecondary)
                            .font(Typography.footnote)
                    }

                    HStack {
                        Text("登録日")
                        Spacer()
                        Text(viewModel.user.createdAt.formatted(date: .long, time: .omitted))
                            .foregroundColor(ColorTokens.textSecondary)
                            .font(Typography.footnote)
                    }

                    HStack {
                        Text("最終アクティブ")
                        Spacer()
                        Text(viewModel.user.lastActiveAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(ColorTokens.textSecondary)
                            .font(Typography.footnote)
                    }

                    HStack {
                        Text("認証方法")
                        Spacer()
                        Text(viewModel.user.authMethod.displayText)
                            .foregroundColor(ColorTokens.textSecondary)
                            .font(Typography.footnote)
                    }
                } header: {
                    Text("アカウント情報")
                }

                // 信頼スコアセクション
                Section {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        HStack {
                            Text("信頼スコア")
                                .font(Typography.headline)
                            Spacer()
                            Text(String(format: "%.1f%%", viewModel.user.trustScore * 100))
                                .font(Typography.title2)
                                .foregroundColor(trustScoreColor)
                        }

                        ProgressView(value: viewModel.user.trustScore)
                            .tint(trustScoreColor)

                        Text("信頼スコアは、アプリの利用状況に基づいて自動的に計算されます。")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                    .padding(.vertical, Spacing.s)
                } header: {
                    Text("信頼性")
                }

                // 統計セクション
                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(ColorTokens.accentPrimary)
                        Text("送信したLike")
                        Spacer()
                        Text("\(viewModel.statistics.sentLikes)")
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .foregroundColor(ColorTokens.accentSuccess)
                        Text("マッチ数")
                        Spacer()
                        Text("\(viewModel.statistics.matchCount)")
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(ColorTokens.accentPrimary)
                        Text("参加コミュニティ")
                        Spacer()
                        Text("\(viewModel.statistics.communityCount)")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                } header: {
                    Text("統計")
                }

                // アカウント操作セクション
                Section {
                    Button {
                        viewModel.showLogoutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(ColorTokens.accentPrimary)
                            Text("ログアウト")
                                .foregroundColor(ColorTokens.accentPrimary)
                        }
                    }

                    Button {
                        viewModel.showDeleteAccountConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(ColorTokens.accentDanger)
                            Text("アカウント削除")
                                .foregroundColor(ColorTokens.accentDanger)
                        }
                    }
                } header: {
                    Text("アカウント操作")
                } footer: {
                    Text("アカウントを削除すると、すべてのデータが完全に削除されます。この操作は取り消せません。")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textSecondary)
                }
            }
            .navigationTitle("アカウント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                title: "ログアウトしますか？",
                message: "再度ログインするまでアプリを利用できません。",
                confirmTitle: "ログアウト",
                confirmRole: nil,
                isPresented: $viewModel.showLogoutConfirmation,
                onConfirm: {
                    viewModel.logout()
                    dismiss()
                }
            )
            .confirmationDialog(
                title: "アカウントを削除しますか？",
                message: "すべてのデータが完全に削除されます。この操作は取り消せません。",
                confirmTitle: "削除",
                confirmRole: .destructive,
                isPresented: $viewModel.showDeleteAccountConfirmation,
                onConfirm: {
                    Task {
                        await viewModel.deleteAccount()
                        dismiss()
                    }
                }
            )
        }
    }

    private var trustScoreColor: Color {
        let score = viewModel.user.trustScore
        if score >= 0.8 {
            return ColorTokens.accentSuccess
        } else if score >= 0.5 {
            return ColorTokens.accentWarning
        } else {
            return ColorTokens.accentDanger
        }
    }
}

// MARK: - ViewModel

@Observable
final class AccountDetailViewModel {
    var user: User
    var statistics: AccountStatistics
    var showLogoutConfirmation = false
    var showDeleteAccountConfirmation = false

    private let userRepository: UserRepository

    init(
        user: User,
        userRepository: UserRepository = RepositoryProvider.shared.userRepository
    ) {
        self.user = user
        self.userRepository = userRepository

        // モック統計データ
        self.statistics = AccountStatistics(
            sentLikes: Int.random(in: 10...50),
            matchCount: Int.random(in: 3...15),
            communityCount: Int.random(in: 1...5)
        )
    }

    func logout() {
        // TODO: 実際はKeychainから認証情報を削除
        print("ログアウトしました")
    }

    @MainActor
    func deleteAccount() async {
        do {
            // TODO: 実際はAPIでアカウント削除
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("アカウントを削除しました")
        } catch {
            print("アカウント削除エラー: \(error)")
        }
    }
}

// MARK: - Models

struct AccountStatistics {
    let sentLikes: Int
    let matchCount: Int
    let communityCount: Int
}

// MARK: - User Extension

extension User {
    enum AuthMethod: String, Codable {
        case phone = "電話番号"
        case apple = "Apple ID"

        var displayText: String {
            rawValue
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailView(
            viewModel: AccountDetailViewModel(user: MockData.currentUser)
        )
        .previewDisplayName("Account Detail View")
    }
}
#endif
