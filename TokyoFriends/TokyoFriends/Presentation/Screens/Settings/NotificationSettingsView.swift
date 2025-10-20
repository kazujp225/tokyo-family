import SwiftUI

/// 通知設定画面
/// デザイン定義: 0.5_デザイン定義.md - 設定画面
struct NotificationSettingsView: View {

    @Bindable var viewModel: NotificationSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // マッチ通知
                Section {
                    Toggle(isOn: $viewModel.settings.matchNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("マッチ通知")
                                .font(Typography.body)
                            Text("新しいマッチが成立したときに通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.likeNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Like通知")
                                .font(Typography.body)
                            Text("誰かがあなたにLikeを送ったときに通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)
                } header: {
                    Text("マッチング")
                }

                // コミュニティ通知
                Section {
                    Toggle(isOn: $viewModel.settings.communityNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("コミュニティ更新")
                                .font(Typography.body)
                            Text("参加中のコミュニティで新しいメンバーが参加したときに通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.newCommunityNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("新着コミュニティ")
                                .font(Typography.body)
                            Text("あなたの興味に合った新しいコミュニティが作成されたときに通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)
                } header: {
                    Text("コミュニティ")
                }

                // システム通知
                Section {
                    Toggle(isOn: $viewModel.settings.recommendationNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("おすすめ通知")
                                .font(Typography.body)
                            Text("あなたにぴったりのユーザーが見つかったときに通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    Toggle(isOn: $viewModel.settings.marketingNotifications) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("お知らせ・キャンペーン")
                                .font(Typography.body)
                            Text("新機能やキャンペーン情報を通知")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)
                } header: {
                    Text("お知らせ")
                }

                // 通知時間帯
                Section {
                    Toggle(isOn: $viewModel.settings.quietHoursEnabled) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("おやすみ時間")
                                .font(Typography.body)
                            Text("指定した時間帯は通知を受け取りません")
                                .font(Typography.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .tint(ColorTokens.accentPrimary)

                    if viewModel.settings.quietHoursEnabled {
                        HStack {
                            Text("開始時刻")
                            Spacer()
                            DatePicker(
                                "",
                                selection: $viewModel.settings.quietHoursStart,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }

                        HStack {
                            Text("終了時刻")
                            Spacer()
                            DatePicker(
                                "",
                                selection: $viewModel.settings.quietHoursEnd,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                    }
                } header: {
                    Text("おやすみ時間")
                }

                // プッシュ通知設定
                Section {
                    if viewModel.notificationPermissionStatus == .authorized {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorTokens.accentSuccess)
                            Text("プッシュ通知が有効です")
                                .font(Typography.footnote)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    } else if viewModel.notificationPermissionStatus == .denied {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(ColorTokens.accentWarning)
                                Text("プッシュ通知が無効です")
                                    .font(Typography.footnote)
                                    .foregroundColor(ColorTokens.textSecondary)
                            }

                            Button("設定を開く") {
                                viewModel.openSettings()
                            }
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.accentPrimary)
                        }
                    } else {
                        Button("プッシュ通知を許可") {
                            Task {
                                await viewModel.requestNotificationPermission()
                            }
                        }
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.accentPrimary)
                    }
                } header: {
                    Text("プッシュ通知")
                } footer: {
                    Text("プッシュ通知を無効にすると、アプリを開いていないときに通知を受け取れません。")
                        .font(Typography.caption)
                }
            }
            .navigationTitle("通知設定")
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
            .task {
                await viewModel.checkNotificationPermission()
            }
        }
    }
}

// MARK: - ViewModel

@Observable
final class NotificationSettingsViewModel {
    var settings: NotificationSettings
    var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined
    var hasChanges = false

    private let initialSettings: NotificationSettings

    init(settings: NotificationSettings = NotificationSettings()) {
        self.settings = settings
        self.initialSettings = settings
    }

    @MainActor
    func checkNotificationPermission() async {
        // TODO: 実際はUNUserNotificationCenterでチェック
        notificationPermissionStatus = .authorized
    }

    @MainActor
    func requestNotificationPermission() async {
        // TODO: 実際はUNUserNotificationCenterで許可リクエスト
        notificationPermissionStatus = .authorized
    }

    func openSettings() {
        // TODO: 実際は設定アプリを開く
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    @MainActor
    func saveSettings() async {
        // TODO: 実際はUserDefaults/APIに保存
        try? await Task.sleep(nanoseconds: 500_000_000)
        print("通知設定を保存しました: \(settings)")
    }
}

// MARK: - Models

struct NotificationSettings: Equatable {
    var matchNotifications = true
    var likeNotifications = true
    var communityNotifications = true
    var newCommunityNotifications = false
    var recommendationNotifications = true
    var marketingNotifications = false
    var quietHoursEnabled = false
    var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0))!
    var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
}

enum NotificationPermissionStatus {
    case notDetermined
    case denied
    case authorized
}

// MARK: - Preview

#if DEBUG
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView(
            viewModel: NotificationSettingsViewModel()
        )
        .previewDisplayName("Notification Settings View")
    }
}
#endif
