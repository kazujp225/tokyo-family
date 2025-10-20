import SwiftUI

/// 基本情報入力画面
/// 画面ID: PG-05 - 基本属性（0.4_ページ定義.md）
/// - 年齢範囲
/// - 属性（学生 or 社会人）
/// - 学校/職場
/// - 地域
/// - 最寄り駅
struct BasicInfoView: View {

    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // タイトル
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("基本情報を\n教えてください")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("プロフィールに表示される情報です")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                .padding(.top, Spacing.xl)

                // 年齢範囲
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("年齢範囲")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    Picker("年齢範囲", selection: $viewModel.profile.ageRange) {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Text(range.displayText).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 属性
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("属性")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    Picker("属性", selection: $viewModel.profile.attribute) {
                        Text(Attribute.student.displayText).tag(Attribute.student)
                        Text(Attribute.worker.displayText).tag(Attribute.worker)
                    }
                    .pickerStyle(.segmented)
                }

                // 学校/職場
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(viewModel.profile.attribute == .student ? "学校名" : "会社名")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    TextField(
                        viewModel.profile.attribute == .student ? "例: 東京大学" : "例: IT企業",
                        text: $viewModel.profile.schoolOrWork
                    )
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }

                // 地域
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("地域")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    Picker("地域", selection: $viewModel.profile.district) {
                        Text("新宿区").tag("新宿区")
                        Text("渋谷区").tag("渋谷区")
                        Text("港区").tag("港区")
                        Text("千代田区").tag("千代田区")
                        Text("中央区").tag("中央区")
                        Text("台東区").tag("台東区")
                    }
                    .pickerStyle(.menu)
                }

                // 最寄り駅
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("最寄り駅")
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    TextField("例: 新宿駅", text: $viewModel.profile.nearestStation)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                // 次へボタン
                PrimaryButton(
                    title: "次へ",
                    action: {
                        Task {
                            await viewModel.proceedToNext()
                        }
                    },
                    isDisabled: !viewModel.canProceed
                )
                .padding(.top, Spacing.m)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.accentDanger)
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfoView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Basic Info View")
    }
}
#endif
