import SwiftUI

/// 写真管理画面
/// デザイン定義: 0.5_デザイン定義.md - プロフィール編集
struct PhotoManagementView: View {

    @Bindable var viewModel: PhotoManagementViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 説明
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("プロフィール写真")
                            .font(Typography.title2)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("1〜5枚の写真を追加してください。最初の写真がメイン写真として表示されます。")
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 写真枚数インジケーター
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index < viewModel.photos.count ? ColorTokens.accentPrimary : ColorTokens.separator)
                                .frame(width: 8, height: 8)
                        }

                        Spacer()

                        Text("\(viewModel.photos.count)/5")
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    // 写真グリッド
                    LazyVGrid(columns: columns, spacing: Spacing.s) {
                        ForEach(viewModel.photos.indices, id: \.self) { index in
                            photoCell(index: index, isMain: index == 0)
                        }

                        // 追加ボタン
                        if viewModel.photos.count < 5 {
                            addPhotoButton
                        }
                    }

                    // ガイドライン
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("写真のガイドライン")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        guidelineItem(icon: "checkmark.circle.fill", color: .green, text: "あなた自身が写っている写真")
                        guidelineItem(icon: "checkmark.circle.fill", color: .green, text: "顔がはっきり見える写真")
                        guidelineItem(icon: "checkmark.circle.fill", color: .green, text: "適切な服装の写真")
                        guidelineItem(icon: "xmark.circle.fill", color: .red, text: "他人の写真、グループ写真")
                        guidelineItem(icon: "xmark.circle.fill", color: .red, text: "不適切な内容を含む写真")
                        guidelineItem(icon: "xmark.circle.fill", color: .red, text: "過度な加工・フィルター")
                    }
                    .padding(Spacing.m)
                    .background(ColorTokens.bgSection)
                    .cornerRadius(CornerRadius.card)
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("写真管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await viewModel.savePhotos()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePickerPlaceholder(onSelect: { image in
                    viewModel.addPhoto(image)
                })
            }
            .sheet(item: $viewModel.selectedPhotoIndex) { index in
                PhotoDetailView(
                    photo: viewModel.photos[index],
                    isMain: index == 0,
                    onSetMain: {
                        viewModel.setMainPhoto(index: index)
                    },
                    onDelete: {
                        viewModel.deletePhoto(index: index)
                    }
                )
            }
        }
    }

    private func photoCell(index: Int, isMain: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            // 写真プレースホルダー
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(ColorTokens.bgSection)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundColor(ColorTokens.textTertiary)
                )

            // メインバッジ
            if isMain {
                Text("メイン")
                    .font(Typography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(ColorTokens.accentPrimary)
                    .cornerRadius(CornerRadius.chip)
                    .padding(Spacing.xs)
            }
        }
        .onTapGesture {
            viewModel.selectedPhotoIndex = index
        }
    }

    private var addPhotoButton: some View {
        Button {
            viewModel.showImagePicker = true
        } label: {
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(ColorTokens.bgSection)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(ColorTokens.accentPrimary)

                        Text("追加")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                )
        }
    }

    private func guidelineItem(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textSecondary)
        }
    }
}

// MARK: - Photo Detail View

struct PhotoDetailView: View {
    let photo: String
    let isMain: Bool
    let onSetMain: () -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // 写真表示
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(ColorTokens.bgSection)
                    .aspectRatio(0.75, contentMode: .fit)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 100))
                            .foregroundColor(ColorTokens.textTertiary)
                    )
                    .padding(Spacing.l)

                Spacer()

                // アクション
                VStack(spacing: Spacing.m) {
                    if !isMain {
                        PrimaryButton(
                            title: "メイン写真に設定",
                            action: {
                                onSetMain()
                                dismiss()
                            }
                        )
                    }

                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        Text("削除")
                            .font(Typography.callout)
                            .foregroundColor(ColorTokens.accentDanger)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ColorTokens.accentDanger.opacity(0.1))
                            .cornerRadius(CornerRadius.button)
                    }
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Image Picker Placeholder

struct ImagePickerPlaceholder: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundColor(ColorTokens.accentPrimary)

                VStack(spacing: Spacing.s) {
                    Text("写真を選択")
                        .font(Typography.title2)

                    Text("実際の実装ではPHPickerViewControllerを使用して写真を選択します")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(
                    title: "写真を選択（モック）",
                    action: {
                        onSelect("photo_\(Int.random(in: 1...100))")
                        dismiss()
                    }
                )
                .padding(.horizontal, Spacing.xxl)
            }
            .padding(Spacing.l)
            .navigationTitle("写真を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel

@Observable
final class PhotoManagementViewModel {
    var photos: [String]
    var showImagePicker = false
    var selectedPhotoIndex: Int?

    private let initialPhotos: [String]

    init(photos: [String] = []) {
        self.photos = photos.isEmpty ? ["default_photo"] : photos
        self.initialPhotos = self.photos
    }

    var canSave: Bool {
        !photos.isEmpty && photos.count <= 5
    }

    func addPhoto(_ photo: String) {
        guard photos.count < 5 else { return }
        photos.append(photo)
    }

    func deletePhoto(index: Int) {
        guard photos.count > 1 else { return }
        photos.remove(at: index)
    }

    func setMainPhoto(index: Int) {
        let photo = photos.remove(at: index)
        photos.insert(photo, at: 0)
    }

    @MainActor
    func savePhotos() async {
        // TODO: 実際はAPIで写真を保存
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("写真を保存しました: \(photos.count)枚")
    }
}

// MARK: - Preview

#if DEBUG
struct PhotoManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoManagementView(
            viewModel: PhotoManagementViewModel(photos: ["1", "2", "3"])
        )
        .previewDisplayName("Photo Management View")
    }
}
#endif
