import SwiftUI

/// オンボーディングコンテナ
/// 画面ID: PG-05〜09 - オンボーディング（0.4_ページ定義.md）
/// - プログレスバー表示
/// - ステップ間の遷移管理
struct OnboardingContainerView: View {

    @Bindable var viewModel: OnboardingViewModel
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // プログレスバー
            if viewModel.currentStep != .complete {
                progressBar
            }

            // 各ステップの画面
            Group {
                switch viewModel.currentStep {
                case .basicInfo:
                    BasicInfoView(viewModel: viewModel)
                case .interests:
                    InterestsView(viewModel: viewModel)
                case .photos:
                    PhotosView(viewModel: viewModel)
                case .instagram:
                    InstagramView(viewModel: viewModel)
                case .complete:
                    CompleteView(onComplete: onComplete)
                }
            }
            .animation(.easeInOut, value: viewModel.currentStep)
        }
        .background(ColorTokens.bgBase)
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "プロフィールを作成中...")
                }
            }
        )
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: Spacing.s) {
            HStack {
                Text("\(viewModel.currentStep.title)")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)

                Spacer()

                Text("\(viewModel.currentStep.rawValue + 1)/\(OnboardingViewModel.OnboardingStep.allCases.count - 1)")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textTertiary)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.m)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorTokens.secondarySystemFill)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorTokens.accentPrimary)
                        .frame(width: geometry.size.width * viewModel.progressValue, height: 4)
                        .animation(.easeInOut, value: viewModel.progressValue)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.l)
        }
        .padding(.bottom, Spacing.m)
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView(
            viewModel: .make(currentUserId: MockData.currentUser.id),
            onComplete: {}
        )
        .previewDisplayName("Onboarding Container")
    }
}
#endif
