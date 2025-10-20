import SwiftUI

/// Instagram連携画面
/// 画面ID: PG-08 - IGハンドル（0.4_ページ定義.md）
/// - Instagramハンドルを入力（任意）
/// - @なし、3〜30文字
struct InstagramView: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var instagramHandle: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // タイトル
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Instagramを\n連携しましょう")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("マッチ後に相手に公開されます（任意）")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                .padding(.top, Spacing.xl)

                // Instagramアイコン
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.58)) // Instagram色

                // ハンドル入力
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Instagramハンドル")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    HStack {
                        Text("@")
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)

                        TextField("例: tokyofriends", text: $instagramHandle)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Text("3〜30文字、英数字とアンダースコアのみ")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textTertiary)
                }

                // 説明
                VStack(alignment: .leading, spacing: Spacing.s) {
                    HStack(alignment: .top, spacing: Spacing.s) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorTokens.accentSuccess)

                        Text("マッチ成立後に相手に公開されます")
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    HStack(alignment: .top, spacing: Spacing.s) {
                        Image(systemName: "lock.circle.fill")
                            .foregroundColor(ColorTokens.accentPrimary)

                        Text("マッチ前は非公開です")
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                .padding(Spacing.m)
                .background(ColorTokens.bgSection)
                .cornerRadius(CornerRadius.card)

                // ボタン
                VStack(spacing: Spacing.m) {
                    PrimaryButton(
                        title: "完了",
                        action: {
                            Task {
                                // IGハンドルを保存（任意）
                                if !instagramHandle.isEmpty {
                                    // TODO: IGハンドルを保存
                                }
                                await viewModel.proceedToNext()
                            }
                        },
                        isLoading: viewModel.isLoading
                    )

                    SecondaryButton(
                        title: "戻る",
                        action: {
                            viewModel.goBack()
                        },
                        isDisabled: viewModel.isLoading
                    )

                    Button("スキップ") {
                        Task {
                            await viewModel.proceedToNext()
                        }
                    }
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textLink)
                    .disabled(viewModel.isLoading)
                }
                .padding(.top, Spacing.m)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.accentDanger)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct InstagramView_Previews: PreviewProvider {
    static var previews: some View {
        InstagramView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Instagram View")
    }
}
#endif
