import SwiftUI

/// 設定画面
/// 画面ID: PG-60 - 設定（0.4_ページ定義.md）
/// - プロフィール編集
/// - アカウント設定
/// - 安全機能
struct SettingsView: View {

    @Bindable var profileViewModel: ProfileEditViewModel
    @State private var showProfileEdit = false
    @State private var showBlockList = false

    var body: some View {
        NavigationStack {
            List {
                // プロフィールセクション
                Section {
                    if let profile = profileViewModel.profile {
                        ProfilePreviewRow(profile: profile)
                            .onTapGesture {
                                showProfileEdit = true
                            }
                    }
                } header: {
                    Text("プロフィール")
                }

                // アカウントセクション
                Section {
                    NavigationLink {
                        AccountDetailView(
                            viewModel: AccountDetailViewModel(user: MockData.currentUser)
                        )
                    } label: {
                        SettingsRow(
                            icon: "person.circle",
                            title: "アカウント情報",
                            color: ColorTokens.accentPrimary
                        )
                    }

                    NavigationLink {
                        NotificationSettingsView(
                            viewModel: NotificationSettingsViewModel()
                        )
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "通知設定",
                            color: ColorTokens.accentPrimary
                        )
                    }
                } header: {
                    Text("設定")
                }

                // 安全機能セクション
                Section {
                    Button {
                        showBlockList = true
                    } label: {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "ブロックリスト",
                            color: ColorTokens.accentWarning
                        )
                    }

                    NavigationLink {
                        PrivacySettingsView(
                            viewModel: PrivacySettingsViewModel()
                        )
                    } label: {
                        SettingsRow(
                            icon: "lock.fill",
                            title: "プライバシー設定",
                            color: ColorTokens.accentWarning
                        )
                    }
                } header: {
                    Text("安全")
                }

                // サポートセクション
                Section {
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        SettingsRow(
                            icon: "doc.text",
                            title: "利用規約",
                            color: ColorTokens.textSecondary
                        )
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        SettingsRow(
                            icon: "hand.raised.shield",
                            title: "プライバシーポリシー",
                            color: ColorTokens.textSecondary
                        )
                    }

                    NavigationLink {
                        ContactSupportView(
                            viewModel: ContactSupportViewModel()
                        )
                    } label: {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "お問い合わせ",
                            color: ColorTokens.textSecondary
                        )
                    }
                } header: {
                    Text("サポート")
                }

                // アプリ情報
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView(viewModel: profileViewModel)
            }
            .sheet(isPresented: $showBlockList) {
                BlockListView(
                    viewModel: .make(currentUserId: profileViewModel.currentUserId)
                )
            }
            .task {
                await profileViewModel.loadProfile()
            }
        }
    }
}

// MARK: - Profile Preview Row

struct ProfilePreviewRow: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: Spacing.m) {
            // アバター
            Circle()
                .fill(ColorTokens.bgSection)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(ColorTokens.textTertiary)
                )

            // プロフィール情報
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(profile.schoolOrWork)
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                HStack(spacing: Spacing.xs) {
                    Text(profile.ageRange.displayText)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)

                    Text("•")
                        .foregroundColor(ColorTokens.textSecondary)

                    Text(profile.district)
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(ColorTokens.textTertiary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(Typography.body)
                .foregroundColor(ColorTokens.textPrimary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            profileViewModel: .make(currentUserId: MockData.currentUser.id)
        )
        .previewDisplayName("Settings View")
    }
}
#endif
