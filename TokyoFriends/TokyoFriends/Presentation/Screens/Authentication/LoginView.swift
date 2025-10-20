import SwiftUI

/// ログイン画面
/// 画面ID: PG-03 - ログイン（0.4_ページ定義.md）
/// - 電話番号ログイン
/// - Appleでサインイン
struct LoginView: View {

    @Bindable var viewModel: AuthenticationViewModel
    @State private var showTermsOfService = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // ロゴ
            VStack(spacing: Spacing.m) {
                Image(systemName: "person.2.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(ColorTokens.accentPrimary)

                Text("Tokyo Friends")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ColorTokens.textPrimary)

                Text("東京で友達を作ろう")
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textSecondary)
            }

            Spacer()

            // ログインボタン
            VStack(spacing: Spacing.m) {
                // Appleでサインイン
                Button(action: {
                    Task {
                        await viewModel.loginWithApple()
                    }
                }) {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "apple.logo")
                            .font(.title3)

                        Text("Appleでサインイン")
                            .font(Typography.callout)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.black)
                    .cornerRadius(CornerRadius.button)
                }
                .disabled(viewModel.isLoading)

                // 電話番号でログイン
                PrimaryButton(
                    title: "電話番号でログイン",
                    action: {
                        Task {
                            await viewModel.loginWithPhone()
                        }
                    },
                    isLoading: viewModel.isLoading
                )
            }
            .padding(.horizontal, Spacing.l)

            // エラーメッセージ
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.accentDanger)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.l)
            }

            // 利用規約・プライバシーポリシー
            VStack(spacing: Spacing.xs) {
                Text("続けることで、以下に同意したものとみなされます")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textTertiary)

                HStack(spacing: 4) {
                    Button("利用規約") {
                        showTermsOfService = true
                    }
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textLink)

                    Text("・")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textTertiary)

                    Button("プライバシーポリシー") {
                        showPrivacyPolicy = true
                    }
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textLink)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.l)

            Spacer()
                .frame(height: 50)
        }
        .background(ColorTokens.bgBase)
        .accessibilityElement(children: .contain)
        .sheet(isPresented: $showTermsOfService) {
            LegalDocumentView(documentType: .termsOfService)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            LegalDocumentView(documentType: .privacyPolicy)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .make())
            .previewDisplayName("Login View")

        LoginView(viewModel: .make())
            .preferredColorScheme(.dark)
            .previewDisplayName("Login View - Dark")
    }
}
#endif
