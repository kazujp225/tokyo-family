import SwiftUI

/// カード詳細画面（探索からの詳細表示）
/// 画面ID: PG-31 - カード詳細（0.4_ページ定義.md）
/// - プロフィール全情報表示
/// - 写真ギャラリー
/// - Like/Skipボタン
struct CardDetailView: View {

    let card: CardModel
    let profile: Profile
    let onLike: () -> Void
    let onSkip: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhotoIndex: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 写真ギャラリー
                    photoGallery

                    // プロフィール情報
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // 基本情報
                        basicInfo

                        Divider()

                        // 自己紹介
                        if let bio = profile.bio {
                            bioSection(bio)
                            Divider()
                        }

                        // 興味タグ
                        interestsSection

                        Divider()

                        // マッチ度
                        matchScoreSection

                        Divider()

                        // 地域情報
                        locationSection
                    }
                    .padding(Spacing.l)
                }
            }
            .background(ColorTokens.bgBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionButtons
            }
        }
    }

    // MARK: - Photo Gallery

    private var photoGallery: some View {
        TabView(selection: $selectedPhotoIndex) {
            ForEach(0..<max(1, profile.photos.count), id: \.self) { index in
                Rectangle()
                    .fill(ColorTokens.bgSection)
                    .aspectRatio(3/4, contentMode: .fill)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(0..<profile.photos.count, id: \.self) { dotIndex in
                                    Circle()
                                        .fill(dotIndex == selectedPhotoIndex ? Color.white : Color.white.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.bottom, Spacing.m)
                        }
                    )
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 500)
    }

    // MARK: - Basic Info

    private var basicInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(profile.schoolOrWork)
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    HStack(spacing: Spacing.xs) {
                        Text(profile.ageRange.displayText)
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)

                        Text("•")
                            .foregroundColor(ColorTokens.textSecondary)

                        Text(profile.attribute.displayText)
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Bio Section

    private func bioSection(_ bio: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundColor(ColorTokens.accentPrimary)
                Text("自己紹介")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)
            }

            Text(bio)
                .font(Typography.body)
                .foregroundColor(ColorTokens.textPrimary)
                .lineSpacing(Typography.lineSpacing)
        }
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(ColorTokens.accentPrimary)
                Text("興味")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)
            }

            FlowLayout(spacing: Spacing.s) {
                ForEach(profile.interests, id: \.self) { interest in
                    Text(interest)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textPrimary)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.s)
                        .background(ColorTokens.accentPrimary.opacity(0.1))
                        .cornerRadius(CornerRadius.chip)
                }
            }
        }
    }

    // MARK: - Match Score Section

    private var matchScoreSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(ColorTokens.accentPrimary)
                Text("マッチ度")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)
            }

            VStack(spacing: Spacing.m) {
                ScoreRow(
                    title: "興味タグの一致度",
                    score: card.interestMatchScore,
                    weight: "50%"
                )

                ScoreRow(
                    title: "生活圏の近さ",
                    score: card.proximityScore,
                    weight: "30%"
                )

                ScoreRow(
                    title: "共通コミュニティ",
                    value: "\(card.commonCommunitiesCount)個",
                    weight: "20%"
                )
            }
            .padding(Spacing.m)
            .background(ColorTokens.bgSection)
            .cornerRadius(CornerRadius.card)
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(ColorTokens.accentPrimary)
                Text("地域")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)
            }

            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack {
                    Text("地域")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                        .frame(width: 80, alignment: .leading)

                    Text(profile.district)
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)
                }

                HStack {
                    Text("最寄り駅")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                        .frame(width: 80, alignment: .leading)

                    Text(profile.nearestStation)
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.l) {
            // Skipボタン
            Button(action: {
                onSkip()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "xmark")
                    Text("Skip")
                }
                .font(Typography.callout)
                .foregroundColor(ColorTokens.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ColorTokens.bgSection)
                .cornerRadius(CornerRadius.button)
            }

            // Likeボタン
            Button(action: {
                onLike()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Like")
                }
                .font(Typography.callout)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ColorTokens.accentPrimary)
                .cornerRadius(CornerRadius.button)
            }
        }
        .padding(Spacing.l)
        .background(ColorTokens.bgBase)
    }
}

// MARK: - Score Row

struct ScoreRow: View {
    let title: String
    var score: Double?
    var value: String?
    let weight: String

    var body: some View {
        HStack {
            Text(title)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textPrimary)

            Spacer()

            if let score = score {
                Text("\(Int(score * 100))%")
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.accentPrimary)
            } else if let value = value {
                Text(value)
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.accentPrimary)
            }

            Text("(\(weight))")
                .font(Typography.caption)
                .foregroundColor(ColorTokens.textTertiary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let card = MockData.generateCards().first!
        let profile = MockData.profiles.first!

        CardDetailView(
            card: card,
            profile: profile,
            onLike: {},
            onSkip: {}
        )
        .previewDisplayName("Card Detail View")
    }
}
#endif
