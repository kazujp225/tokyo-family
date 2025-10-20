import SwiftUI

/// スプラッシュ画面
/// 画面ID: PG-01 - スプラッシュ（0.4_ページ定義.md）
/// - アプリロゴ表示
/// - 2秒後に自動遷移
struct SplashView: View {

    @Bindable var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    ColorTokens.accentPrimary,
                    ColorTokens.accentPrimary.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // アプリロゴ
                VStack(spacing: Spacing.m) {
                    Image(systemName: "person.2.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)

                    Text("Tokyo Friends")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("東京で友達を作ろう")
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // ローディングインジケータ
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Spacer()
                    .frame(height: 50)
            }
        }
        .task {
            await viewModel.checkAuthenticationStatus()
        }
        .accessibilityLabel("Tokyo Friends スプラッシュ画面")
    }
}

// MARK: - Preview

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(viewModel: .make())
            .previewDisplayName("Splash View")
    }
}
#endif
