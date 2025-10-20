import SwiftUI

/// プロフィールカード（スワイプ用）
/// デザイン定義: 0.5_デザイン定義.md - 4.1 カード
/// 画面ID: PG-30 - カード探索（0.4_ページ定義.md）
/// - 角丸: 12pt
/// - 影: Elevation 1
/// - 写真 + プロフィール情報 + スコア表示
struct ProfileCardView: View {

    // MARK: - Properties

    let card: CardModel
    let profile: Profile

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // メイン写真
            mainPhoto

            // プロフィール情報
            VStack(alignment: .leading, spacing: Spacing.s) {
                // 年齢範囲 + 属性
                HStack(spacing: Spacing.xs) {
                    Text(profile.ageRange.displayText)
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("•")
                        .foregroundColor(ColorTokens.textSecondary)

                    Text(profile.attribute.displayText)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                }

                // 学校/職場
                Text(profile.schoolOrWork)
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)

                // 地域 + 最寄り駅
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(ColorTokens.textTertiary)

                    Text("\(profile.district) • \(profile.nearestStation)")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textTertiary)
                }

                // 興味タグ（最大3つ）
                interestTags

                // マッチ度スコア
                matchScoreBar
            }
            .padding(Spacing.m)
        }
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
        .shadow(
            color: Color.black.opacity(Elevation.one.opacity),
            radius: Elevation.one.blur,
            x: 0,
            y: Elevation.one.yOffset
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Subviews

    private var mainPhoto: some View {
        Rectangle()
            .fill(ColorTokens.bgSection)
            .aspectRatio(3/4, contentMode: .fit)
            .overlay(
                // 実際の写真があればここに表示
                Text("写真")
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textTertiary)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: CornerRadius.card)
            )
    }

    private var interestTags: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(Array(profile.interests.prefix(3)), id: \.self) { interest in
                Text(interest)
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textSecondary)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical: 4)
                    .background(ColorTokens.secondarySystemFill)
                    .cornerRadius(CornerRadius.chip)
            }

            if profile.interests.count > 3 {
                Text("+\(profile.interests.count - 3)")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textTertiary)
            }
        }
    }

    private var matchScoreBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("マッチ度")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textTertiary)

                Spacer()

                Text("\(Int(card.totalScore * 100))%")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.accentPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorTokens.secondarySystemFill)
                        .frame(height: 4)

                    // スコアバー
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorTokens.accentPrimary)
                        .frame(width: geometry.size.width * card.totalScore, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        """
        \(profile.ageRange.displayText)、\(profile.attribute.displayText)、\
        \(profile.schoolOrWork)、\(profile.district)、\(profile.nearestStation)、\
        興味: \(profile.interests.prefix(3).joined(separator: "、"))、\
        マッチ度 \(Int(card.totalScore * 100))パーセント
        """
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileCardView_Previews: PreviewProvider {
    static var previews: some View {
        let card = MockData.generateCards().first!
        let profile = MockData.profiles.first!

        VStack {
            ProfileCardView(card: card, profile: profile)
                .padding()
        }
        .background(ColorTokens.bgBase)
        .previewDisplayName("Profile Card")
    }
}
#endif
