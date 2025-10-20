import SwiftUI

/// パルスボタン（強調表示用）
/// デザイン定義: 0.5_デザイン定義.md - 4.6 アニメーション
struct PulseButton: View {

    let icon: String
    let action: () -> Void
    var color: Color = ColorTokens.accentPrimary
    var size: CGFloat = 70

    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // パルスエフェクト
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: size, height: size)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                        value: isPulsing
                    )

                // メインボタン
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .shadow(
                        color: color.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                Image(systemName: icon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PulseButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.xxl) {
            PulseButton(icon: "heart.fill", action: {})

            PulseButton(
                icon: "xmark",
                action: {},
                color: ColorTokens.textTertiary,
                size: 60
            )
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Pulse Button")
    }
}
#endif
