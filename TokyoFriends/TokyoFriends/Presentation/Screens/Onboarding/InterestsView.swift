import SwiftUI

/// 興味タグ選択画面
/// 画面ID: PG-06 - 興味タグ（0.4_ページ定義.md）
/// - 3〜10個の興味タグを選択
/// - チップUI（選択状態を視覚化）
struct InterestsView: View {

    @Bindable var viewModel: OnboardingViewModel

    // グリッドレイアウト
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: Spacing.s)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // タイトル
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("興味のあることを\n選んでください")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("3〜10個選択してください（\(viewModel.selectedInterests.count)/10）")
                        .font(Typography.footnote)
                        .foregroundColor(
                            viewModel.canProceed ? ColorTokens.accentSuccess : ColorTokens.textSecondary
                        )
                }
                .padding(.top, Spacing.xl)

                // 興味タググリッド
                LazyVGrid(columns: columns, spacing: Spacing.m) {
                    ForEach(OnboardingViewModel.availableInterests, id: \.self) { interest in
                        InterestChip(
                            title: interest,
                            isSelected: viewModel.selectedInterests.contains(interest),
                            action: {
                                viewModel.toggleInterest(interest)
                            }
                        )
                    }
                }

                // ボタン
                VStack(spacing: Spacing.m) {
                    PrimaryButton(
                        title: "次へ",
                        action: {
                            Task {
                                await viewModel.proceedToNext()
                            }
                        },
                        isDisabled: !viewModel.canProceed
                    )

                    SecondaryButton(
                        title: "戻る",
                        action: {
                            viewModel.goBack()
                        }
                    )
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
struct InterestsView_Previews: PreviewProvider {
    static var previews: some View {
        InterestsView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Interests View")
    }
}
#endif
