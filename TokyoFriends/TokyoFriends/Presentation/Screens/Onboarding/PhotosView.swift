import SwiftUI

/// 写真追加画面
/// 画面ID: PG-07 - 写真（0.4_ページ定義.md）
/// - 1〜5枚の写真を追加
/// - 写真の順序変更
struct PhotosView: View {

    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // タイトル
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("写真を追加してください")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("1〜5枚追加できます（\(viewModel.profile.photos.count)/5）")
                        .font(Typography.footnote)
                        .foregroundColor(
                            viewModel.canProceed ? ColorTokens.accentSuccess : ColorTokens.textSecondary
                        )
                }
                .padding(.top, Spacing.xl)

                // 写真グリッド
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: Spacing.m
                ) {
                    // 既存の写真
                    ForEach(viewModel.profile.photos, id: \.self) { photoURL in
                        photoThumbnail(photoURL)
                    }

                    // 追加ボタン
                    if viewModel.profile.photos.count < 5 {
                        addPhotoButton
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

    // MARK: - Subviews

    private func photoThumbnail(_ photoURL: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(ColorTokens.bgSection)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Text("写真")
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textTertiary)
                )
                .cornerRadius(CornerRadius.thumbnail)

            // 削除ボタン
            Button(action: {
                viewModel.removePhoto(photoURL)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(Spacing.xs)
        }
    }

    private var addPhotoButton: some View {
        Button(action: {
            // TODO: 写真ピッカーを開く
            // モックとして仮のURLを追加
            viewModel.addPhoto("photo_\(UUID().uuidString)")
        }) {
            VStack(spacing: Spacing.s) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(ColorTokens.accentPrimary)

                Text("写真を追加")
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(ColorTokens.secondarySystemFill)
            .cornerRadius(CornerRadius.thumbnail)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Photos View")
    }
}
#endif
