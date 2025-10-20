import SwiftUI

/// マッチ詳細画面
/// 画面ID: PG-41 - マッチ詳細（0.4_ページ定義.md）
/// - マッチ成立した相手のプロフィール詳細表示
/// - Instagram連携
/// - ブロック・通報機能
struct MatchDetailView: View {

    let match: Match
    @Bindable var viewModel: MatchDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // プロフィール写真
                    photoSection

                    // 基本情報
                    if let profile = viewModel.profile {
                        basicInfoSection(profile: profile)

                        // 地域情報
                        locationSection(profile: profile)

                        // 興味タグ
                        interestsSection(profile: profile)

                        // 自己紹介
                        if let bio = profile.bio, !bio.isEmpty {
                            bioSection(bio: bio)
                        }
                    }

                    // Instagram連携
                    if let instagramHandle = match.partnerInstagramHandle {
                        instagramSection(handle: instagramHandle)
                    }

                    // マッチ情報
                    matchInfoSection

                    // アクション
                    actionButtons
                }
                .padding(.vertical, Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("マッチ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.showBlockConfirmation = true
                        } label: {
                            Label("ブロック", systemImage: "hand.raised.fill")
                        }

                        Button {
                            viewModel.showReportSheet = true
                        } label: {
                            Label("通報", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .confirmationDialog(
                "このユーザーをブロックしますか？",
                isPresented: $viewModel.showBlockConfirmation,
                titleVisibility: .visible
            ) {
                Button("ブロック", role: .destructive) {
                    Task {
                        await viewModel.blockUser()
                        dismiss()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("ブロックすると、お互いのプロフィールが表示されなくなり、メッセージも削除されます。")
            }
            .sheet(isPresented: $viewModel.showReportSheet) {
                ReportView(
                    viewModel: .make(
                        reportedUserId: match.partnerId,
                        reportContext: .match
                    )
                )
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        Group {
            if viewModel.isLoading {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(ColorTokens.bgSection)
                    .frame(height: 400)
                    .shimmer(isLoading: true)
                    .padding(.horizontal, Spacing.l)
            } else {
                TabView {
                    ForEach(viewModel.profile?.photos ?? [], id: \.self) { photo in
                        RoundedRectangle(cornerRadius: CornerRadius.card)
                            .fill(ColorTokens.bgSection)
                            .frame(height: 400)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 100))
                                    .foregroundColor(ColorTokens.textTertiary)
                            )
                    }
                }
                .frame(height: 400)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }

    // MARK: - Basic Info Section

    private func basicInfoSection(profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(profile.schoolOrWork)
                        .font(Typography.title1)
                        .foregroundColor(ColorTokens.textPrimary)

                    HStack(spacing: Spacing.s) {
                        Text(profile.ageRange.displayText)
                            .font(Typography.callout)
                            .foregroundColor(ColorTokens.textSecondary)

                        Text("•")
                            .foregroundColor(ColorTokens.textSecondary)

                        Text(profile.attribute.displayText)
                            .font(Typography.callout)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Location Section

    private func locationSection(profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(ColorTokens.accentPrimary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("地域")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textSecondary)

                    Text("\(profile.district) • \(profile.nearestStation)")
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)
                }

                Spacer()
            }
            .padding(Spacing.m)
            .background(ColorTokens.bgCard)
            .cornerRadius(CornerRadius.card)
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Interests Section

    private func interestsSection(profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("興味")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textPrimary)

            FlowLayout(spacing: Spacing.s) {
                ForEach(profile.interests, id: \.self) { interest in
                    InterestChip(
                        title: interest,
                        isSelected: true,
                        action: {}
                    )
                    .disabled(true)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Bio Section

    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("自己紹介")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textPrimary)

            Text(bio)
                .font(Typography.body)
                .foregroundColor(ColorTokens.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Instagram Section

    private func instagramSection(handle: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Instagram")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textPrimary)

            Button {
                viewModel.openInstagram(handle: handle)
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(handle)")
                            .font(Typography.callout)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("Instagramで開く")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .foregroundColor(ColorTokens.textTertiary)
                }
                .padding(Spacing.m)
                .background(ColorTokens.bgCard)
                .cornerRadius(CornerRadius.card)
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Match Info Section

    private var matchInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("マッチ情報")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textPrimary)

            VStack(spacing: Spacing.s) {
                infoRow(
                    icon: "checkmark.circle.fill",
                    label: "マッチ成立日",
                    value: viewModel.formattedMatchDate
                )

                if !match.commonCommunityIds.isEmpty {
                    infoRow(
                        icon: "person.3.fill",
                        label: "共通のコミュニティ",
                        value: "\(match.commonCommunityIds.count)個"
                    )
                }
            }
            .padding(Spacing.m)
            .background(ColorTokens.bgCard)
            .cornerRadius(CornerRadius.card)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorTokens.accentPrimary)
                .frame(width: 24)

            Text(label)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textSecondary)

            Spacer()

            Text(value)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textPrimary)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Spacing.m) {
            if let instagramHandle = match.partnerInstagramHandle {
                PrimaryButton(
                    title: "Instagramで開く",
                    action: {
                        viewModel.openInstagram(handle: instagramHandle)
                    }
                )
            }
        }
        .padding(.horizontal, Spacing.l)
    }
}

// MARK: - ViewModel

@Observable
final class MatchDetailViewModel {
    var profile: Profile?
    var isLoading = false
    var showBlockConfirmation = false
    var showReportSheet = false

    private let match: Match
    private let userRepository: UserRepository

    init(match: Match, userRepository: UserRepository) {
        self.match = match
        self.userRepository = userRepository
    }

    var formattedMatchDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: match.createdAt)
    }

    @MainActor
    func loadProfile() async {
        isLoading = true

        do {
            profile = try await userRepository.fetchProfile(userId: match.partnerId)
        } catch {
            print("プロフィール読み込みエラー: \(error)")
        }

        isLoading = false
    }

    @MainActor
    func blockUser() async {
        do {
            try await userRepository.blockUser(userId: match.partnerId)
            print("ユーザーをブロックしました")
        } catch {
            print("ブロックエラー: \(error)")
        }
    }

    func openInstagram(handle: String) {
        let instagramURL = URL(string: "instagram://user?username=\(handle)")
        let webURL = URL(string: "https://www.instagram.com/\(handle)")

        if let instagramURL = instagramURL, UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
        } else if let webURL = webURL {
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - Factory

extension MatchDetailViewModel {
    static func make(match: Match) -> MatchDetailViewModel {
        MatchDetailViewModel(
            match: match,
            userRepository: MockUserRepository()
        )
    }
}

// MARK: - Preview

#if DEBUG
struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(
            match: MockData.matches[0],
            viewModel: .make(match: MockData.matches[0])
        )
        .previewDisplayName("Match Detail View")
    }
}
#endif
