import SwiftUI

/// セカンダリボタン（補助的なアクション）
/// デザイン定義: 0.5_デザイン定義.md - 4.2 ボタン
/// - 背景: 透明 or SecondarySystemFill
/// - ボーダー: Separator色
/// - 高さ: 48pt
struct SecondaryButton: View {

    // MARK: - Properties

    let title: String
    let action: () -> Void
    var style: Style = .outlined
    var isDisabled: Bool = false
    var fullWidth: Bool = true

    // MARK: - Style

    enum Style {
        case outlined // ボーダーのみ
        case filled   // 背景あり
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.callout)
                .foregroundColor(
                    isDisabled ? ColorTokens.textTertiary : ColorTokens.textPrimary
                )
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: 48)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.button)
                        .stroke(borderColor, lineWidth: 1)
                )
                .cornerRadius(CornerRadius.button)
        }
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isDisabled ? [.isButton, .isNotEnabled] : .isButton)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        switch style {
        case .outlined:
            return .clear
        case .filled:
            return isDisabled ? ColorTokens.bgSection : ColorTokens.secondarySystemFill
        }
    }

    private var borderColor: Color {
        isDisabled ? ColorTokens.lineSeparator : ColorTokens.lineOpaque
    }
}

// MARK: - Preview

#if DEBUG
struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.l) {
            SecondaryButton(title: "スキップ", action: {})

            SecondaryButton(title: "キャンセル", action: {}, style: .filled)

            SecondaryButton(title: "無効状態", action: {}, isDisabled: true)
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Secondary Button")
    }
}
#endif
