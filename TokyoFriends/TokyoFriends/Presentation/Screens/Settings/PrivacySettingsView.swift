import SwiftUI

/// プライバシー設定画面
/// デザイン定義: 0.5_デザイン定義.md - 設定画面
struct PrivacySettingsView: View {

    @Bindable var viewModel: PrivacySettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // プロフィール公開設定
                Section {
                    Toggle(isOn: $viewModel.settings.showAgeRange) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("年齢範囲を表示")
                                .font(Typography.body)
                            Text("プロフィールに年齢範囲を表示します")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.showLocation) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("地域情報を表示")
                                .font(Typography.body)
                            Text("プロフィールに地域・最寄り駅を表示します")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.showInstagram) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Instagramを表示")
                                .font(Typography.body)
                            Text("マッチ成立後にInstagramハンドルを公開します")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)
                } header: {
                    Text("プロフィール公開")
                }

                // 探索設定
                Section {
                    Toggle(isOn: $viewModel.settings.appearsInExplore) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("探索画面に表示")
                                .font(Typography.body)
                            Text("オフにすると他のユーザーのカードデッキに表示されません")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Picker("表示対象", selection: $viewModel.settings.visibilityMode) {
                        ForEach(VisibilityMode.allCases, id: \.self) { mode in
                            Text(mode.displayText).tag(mode)
                        }
                    }
                    .disabled(!viewModel.settings.appearsInExplore)
                } header: {
                    Text("探索設定")
                } footer: {
                    Text("「同じコミュニティのみ」を選択すると、参加中のコミュニティメンバーにのみ表示されます。")
                        .font(Typography.caption)
                }

                // データ収集
                Section {
                    Toggle(isOn: $viewModel.settings.allowAnalytics) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("利用状況の分析")
                                .font(Typography.body)
                            Text("アプリの改善のため、匿名化された利用データを収集します")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.allowPersonalization) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("パーソナライズ")
                                .font(Typography.body)
                            Text("あなたの興味に合わせたおすすめを表示します")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)
                } header: {
                    Text("データ利用")
                }

                // データダウンロード・削除
                Section {
                    Button {
                        Task {
                            await viewModel.requestDataDownload()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(ColorTokens.accentPrimary)
                            Text("データをダウンロード")
                            Spacer()
                            if viewModel.isDownloading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isDownloading)

                    NavigationLink {
                        DataDeletionView()
                    } label: {
                        HStack {
                            Image(systemName: "trash.circle")
                                .foregroundColor(ColorTokens.accentDanger)
                            Text("データを削除")
                        }
                    }
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("GDPRおよび個人情報保護法に基づき、あなたのデータをダウンロードまたは削除できます。")
                        .font(Typography.caption)
                }
            }
            .navigationTitle("プライバシー設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await viewModel.saveSettings()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
            .alert("ダウンロード完了", isPresented: $viewModel.showDownloadSuccess) {
                Button("OK") {
                    viewModel.showDownloadSuccess = false
                }
            } message: {
                Text("データのダウンロードリンクをメールで送信しました。")
            }
        }
    }
}

// MARK: - ViewModel

@Observable
final class PrivacySettingsViewModel {
    var settings: PrivacySettings
    var hasChanges = false
    var isDownloading = false
    var showDownloadSuccess = false

    private let initialSettings: PrivacySettings

    init(settings: PrivacySettings = PrivacySettings()) {
        self.settings = settings
        self.initialSettings = settings
    }

    @MainActor
    func requestDataDownload() async {
        isDownloading = true

        // TODO: 実際はAPIでデータエクスポートリクエスト
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        isDownloading = false
        showDownloadSuccess = true
    }

    @MainActor
    func saveSettings() async {
        // TODO: 実際はUserDefaults/APIに保存
        try? await Task.sleep(nanoseconds: 500_000_000)
        print("プライバシー設定を保存しました: \(settings)")
    }
}

// MARK: - Models

struct PrivacySettings: Equatable {
    var showAgeRange = true
    var showLocation = true
    var showInstagram = true
    var appearsInExplore = true
    var visibilityMode: VisibilityMode = .everyone
    var allowAnalytics = true
    var allowPersonalization = true
}

enum VisibilityMode: String, CaseIterable {
    case everyone = "すべてのユーザー"
    case sameCommunities = "同じコミュニティのみ"
    case sameDistrict = "同じ地域のみ"

    var displayText: String {
        rawValue
    }
}

// MARK: - Data Deletion View

struct DataDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var confirmationText = ""
    @State private var showDeletionSuccess = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(ColorTokens.accentDanger)

                    Text("データ削除の確認")
                        .font(Typography.title2)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text("以下のデータがすべて削除されます：")
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textSecondary)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        bulletPoint("プロフィール情報")
                        bulletPoint("マッチ履歴")
                        bulletPoint("コミュニティ参加履歴")
                        bulletPoint("Like/Skip履歴")
                        bulletPoint("すべての写真")
                    }
                    .padding(.leading, Spacing.m)
                }
                .padding(.vertical, Spacing.m)
            }

            Section {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("「削除」と入力して確認してください")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)

                    TextField("削除", text: $confirmationText)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                }
            }

            Section {
                Button {
                    showDeletionSuccess = true
                } label: {
                    Text("すべてのデータを削除")
                        .foregroundColor(ColorTokens.accentDanger)
                        .frame(maxWidth: .infinity)
                }
                .disabled(confirmationText != "削除")
            }
        }
        .navigationTitle("データ削除")
        .navigationBarTitleDisplayMode(.inline)
        .alert("削除完了", isPresented: $showDeletionSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("すべてのデータを削除しました。14日以内であれば復元できます。")
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Text("•")
                .foregroundColor(ColorTokens.textSecondary)
            Text(text)
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textSecondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PrivacySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySettingsView(
            viewModel: PrivacySettingsViewModel()
        )
        .previewDisplayName("Privacy Settings View")
    }
}
#endif
