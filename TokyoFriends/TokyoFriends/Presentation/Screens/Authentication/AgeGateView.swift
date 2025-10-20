import SwiftUI

/// 年齢確認画面
/// 画面ID: PG-02 - 年齢確認（0.4_ページ定義.md）
/// 機能ID: F-09 - 年齢認証（0.3_機能定義.md）
/// - 18歳以上かどうかの確認
/// - 未成年の場合は利用不可
struct AgeGateView: View {

    @Bindable var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // アイコン
            Image(systemName: "person.badge.shield.checkmark.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.accentPrimary)

            // タイトル
            VStack(spacing: Spacing.s) {
                Text("年齢確認")
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("Tokyo Friendsは18歳以上の方のみ\nご利用いただけます")
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(Typography.lineSpacing)
            }

            Spacer()

            // ボタン
            VStack(spacing: Spacing.m) {
                PrimaryButton(
                    title: "18歳以上です",
                    action: {
                        Task {
                            await viewModel.confirmAge(isOver18: true)
                        }
                    }
                )

                SecondaryButton(
                    title: "18歳未満です",
                    action: {
                        Task {
                            await viewModel.confirmAge(isOver18: false)
                        }
                    }
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

            Spacer()
                .frame(height: 50)
        }
        .background(ColorTokens.bgBase)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview

#if DEBUG
struct AgeGateView_Previews: PreviewProvider {
    static var previews: some View {
        AgeGateView(viewModel: .make())
            .previewDisplayName("Age Gate View")
    }
}
#endif
