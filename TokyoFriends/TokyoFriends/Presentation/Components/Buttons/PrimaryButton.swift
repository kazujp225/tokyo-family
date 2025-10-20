import SwiftUI

/// プライマリボタン（主要CTA）
/// デザイン定義: 0.5_デザイン定義.md - 4.2 ボタン
/// - 高さ: 48pt（タップ領域確保）
/// - 角丸: 10pt
/// - フォント: Callout (16pt Medium)
struct PrimaryButton: View {

    // MARK: - Properties

    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = true

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }

                Text(title)
                    .font(Typography.callout)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 48)
            .background(
                isDisabled ? ColorTokens.textTertiary : ColorTokens.accentPrimary
            )
            .cornerRadius(CornerRadius.button)
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "読み込み中" : "")
        .accessibilityAddTraits(isDisabled ? [.isButton, .isNotEnabled] : .isButton)
    }
}

// MARK: - Preview

#if DEBUG
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.l) {
            PrimaryButton(title: "次へ", action: {})

            PrimaryButton(title: "読み込み中", action: {}, isLoading: true)

            PrimaryButton(title: "無効状態", action: {}, isDisabled: true)

            PrimaryButton(title: "幅自動", action: {}, fullWidth: false)
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Primary Button")
    }
}
#endif
