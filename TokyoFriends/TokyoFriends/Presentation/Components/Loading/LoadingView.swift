import SwiftUI

/// ローディングビュー（全画面オーバーレイ）
/// デザイン定義: 0.5_デザイン定義.md - 4.5 その他
struct LoadingView: View {

    var message: String = "読み込み中..."

    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // ローディングカード
            VStack(spacing: Spacing.m) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.accentPrimary))
                    .scaleEffect(1.5)

                Text(message)
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
            }
            .padding(Spacing.xl)
            .background(ColorTokens.bgCard)
            .cornerRadius(CornerRadius.card)
            .shadow(
                color: Color.black.opacity(Elevation.two.opacity),
                radius: Elevation.two.blur,
                x: 0,
                y: Elevation.two.yOffset
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Preview

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .previewDisplayName("Loading View")
    }
}
#endif
