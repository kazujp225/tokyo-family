import SwiftUI

/// シマー効果（ローディング中のプレースホルダー）
/// デザイン定義: 0.5_デザイン定義.md - 4.6 アニメーション
struct ShimmerView: View {

    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ColorTokens.secondarySystemFill

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                ColorTokens.bgBase.opacity(0.6),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Modifier

extension View {
    /// シマー効果を適用
    func shimmer(isLoading: Bool) -> some View {
        ZStack {
            self.opacity(isLoading ? 0.3 : 1)

            if isLoading {
                ShimmerView()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ShimmerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.l) {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(ColorTokens.bgCard)
                .frame(height: 100)
                .shimmer(isLoading: true)

            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(ColorTokens.bgCard)
                .frame(height: 60)
                .shimmer(isLoading: true)
        }
        .padding()
        .background(ColorTokens.bgBase)
        .previewDisplayName("Shimmer View")
    }
}
#endif
