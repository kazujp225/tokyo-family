import SwiftUI

/// コミュニティカード
/// デザイン定義: 0.5_デザイン定義.md - 4.1 カード
/// 画面ID: PG-20 - コミュニティ一覧（0.4_ページ定義.md）
struct CommunityCardView: View {

    // MARK: - Properties

    let community: Community
    let isJoined: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                // タイトル（地域×興味タグ）
                Text(community.generatedName)
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                // 説明
                if let description = community.description {
                    Text(description)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                        .lineLimit(2)
                }

                HStack {
                    // 参加者数
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(ColorTokens.textTertiary)

                        Text("\(community.participantCount)人")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textTertiary)
                    }

                    Spacer()

                    // 参加状態
                    if isJoined {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(ColorTokens.accentSuccess)

                            Text("参加中")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.accentSuccess)
                        }
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical: 4)
                        .background(ColorTokens.accentSuccess.opacity(0.1))
                        .cornerRadius(CornerRadius.pill)
                    }
                }
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorTokens.bgCard)
            .cornerRadius(CornerRadius.card)
            .shadow(
                color: Color.black.opacity(Elevation.one.opacity),
                radius: Elevation.one.blur,
                x: 0,
                y: Elevation.one.yOffset
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(community.generatedName)、\(community.participantCount)人、\(isJoined ? "参加中" : "")")
        .accessibilityHint("タップして詳細を表示")
    }
}

// MARK: - Preview

#if DEBUG
struct CommunityCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.m) {
            CommunityCardView(
                community: MockData.communities[0],
                isJoined: true,
                onTap: {}
            )

            CommunityCardView(
                community: MockData.communities[1],
                isJoined: false,
                onTap: {}
            )
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Community Card")
    }
}
#endif
