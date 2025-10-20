import SwiftUI

/// 興味タグチップ（選択可能）
/// デザイン定義: 0.5_デザイン定義.md - 4.3 チップ
/// - 角丸: 10pt
/// - 高さ: 32pt
/// - 選択時: accentPrimary背景 + 白文字
/// - 未選択時: secondarySystemFill背景 + textPrimary
struct InterestChip: View {

    // MARK: - Properties

    let title: String
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.footnote)
                .foregroundColor(textColor)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.xs)
                .background(backgroundColor)
                .cornerRadius(CornerRadius.chip)
        }
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "選択済み。タップして解除" : "タップして選択")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        isSelected ? ColorTokens.accentPrimary : ColorTokens.secondarySystemFill
    }

    private var textColor: Color {
        isSelected ? .white : ColorTokens.textPrimary
    }
}

// MARK: - Preview

#if DEBUG
struct InterestChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.m) {
            HStack {
                InterestChip(title: "カフェ", isSelected: true, action: {})
                InterestChip(title: "サウナ", isSelected: false, action: {})
                InterestChip(title: "写真", isSelected: false, action: {})
            }

            // ダークモード
            HStack {
                InterestChip(title: "音楽", isSelected: true, action: {})
                InterestChip(title: "アート", isSelected: false, action: {})
            }
            .preferredColorScheme(.dark)
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Interest Chip")
    }
}
#endif
