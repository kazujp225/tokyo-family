import SwiftUI

/// バッジコンポーネント（通知数・ステータス表示）
/// デザイン定義: 0.5_デザイン定義.md - 4.4 バッジ
struct BadgeView: View {

    let text: String
    var style: BadgeStyle = .primary
    var size: BadgeSize = .medium

    enum BadgeStyle {
        case primary
        case success
        case warning
        case danger
        case neutral

        var color: Color {
            switch self {
            case .primary: return ColorTokens.accentPrimary
            case .success: return ColorTokens.accentSuccess
            case .warning: return ColorTokens.accentWarning
            case .danger: return ColorTokens.accentDanger
            case .neutral: return ColorTokens.textSecondary
            }
        }
    }

    enum BadgeSize {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return Typography.caption
            case .medium: return Typography.footnote
            case .large: return Typography.body
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }

    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(.white)
            .padding(.horizontal, size.padding * 1.5)
            .padding(.vertical, size.padding)
            .background(style.color)
            .cornerRadius(CornerRadius.pill)
    }
}

// MARK: - Numbered Badge (for notifications)

struct NumberedBadge: View {
    let count: Int
    var maxCount: Int = 99

    var body: some View {
        if count > 0 {
            Text(count > maxCount ? "\(maxCount)+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 18, minHeight: 18)
                .background(ColorTokens.accentDanger)
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.l) {
            HStack(spacing: Spacing.m) {
                BadgeView(text: "新着", style: .primary)
                BadgeView(text: "参加中", style: .success)
                BadgeView(text: "注意", style: .warning)
                BadgeView(text: "エラー", style: .danger)
                BadgeView(text: "未読", style: .neutral)
            }

            HStack(spacing: Spacing.m) {
                BadgeView(text: "Small", size: .small)
                BadgeView(text: "Medium", size: .medium)
                BadgeView(text: "Large", size: .large)
            }

            HStack(spacing: Spacing.xl) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title)
                        .foregroundColor(ColorTokens.textPrimary)

                    NumberedBadge(count: 5)
                        .offset(x: 8, y: -8)
                }

                ZStack(alignment: .topTrailing) {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(ColorTokens.textPrimary)

                    NumberedBadge(count: 99)
                        .offset(x: 8, y: -8)
                }

                ZStack(alignment: .topTrailing) {
                    Image(systemName: "message.fill")
                        .font(.title)
                        .foregroundColor(ColorTokens.textPrimary)

                    NumberedBadge(count: 150)
                        .offset(x: 8, y: -8)
                }
            }
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Badge Views")
    }
}
#endif
