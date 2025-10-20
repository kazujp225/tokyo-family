import SwiftUI

/// プロフィール編集画面
/// 画面ID: PG-61 - プロフィール編集（0.4_ページ定義.md）
/// 機能ID: F-02 - プロフィール編集（0.3_機能定義.md）
struct ProfileEditView: View {

    @Bindable var viewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                Section {
                    if let profile = viewModel.profile {
                        Picker("年齢範囲", selection: Binding(
                            get: { profile.ageRange },
                            set: { viewModel.profile?.ageRange = $0 }
                        )) {
                            ForEach(AgeRange.allCases, id: \.self) { range in
                                Text(range.displayText).tag(range)
                            }
                        }

                        Picker("属性", selection: Binding(
                            get: { profile.attribute },
                            set: { viewModel.profile?.attribute = $0 }
                        )) {
                            Text(Attribute.student.displayText).tag(Attribute.student)
                            Text(Attribute.worker.displayText).tag(Attribute.worker)
                        }

                        TextField(
                            profile.attribute == .student ? "学校名" : "会社名",
                            text: Binding(
                                get: { profile.schoolOrWork },
                                set: { viewModel.profile?.schoolOrWork = $0 }
                            )
                        )
                    }
                } header: {
                    Text("基本情報")
                }

                // 地域セクション
                Section {
                    if let profile = viewModel.profile {
                        Picker("地域", selection: Binding(
                            get: { profile.district },
                            set: { viewModel.profile?.district = $0 }
                        )) {
                            Text("新宿区").tag("新宿区")
                            Text("渋谷区").tag("渋谷区")
                            Text("港区").tag("港区")
                            Text("千代田区").tag("千代田区")
                            Text("中央区").tag("中央区")
                            Text("台東区").tag("台東区")
                        }

                        TextField("最寄り駅", text: Binding(
                            get: { profile.nearestStation },
                            set: { viewModel.profile?.nearestStation = $0 }
                        ))
                    }
                } header: {
                    Text("地域")
                }

                // 自己紹介セクション
                Section {
                    if let profile = viewModel.profile {
                        TextEditor(text: Binding(
                            get: { profile.bio ?? "" },
                            set: { viewModel.profile?.bio = $0.isEmpty ? nil : $0 }
                        ))
                        .frame(height: 100)

                        Text("\(profile.bio?.count ?? 0)/300")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textTertiary)
                    }
                } header: {
                    Text("自己紹介")
                } footer: {
                    Text("最大300文字まで入力できます")
                }

                // 興味タグセクション
                Section {
                    NavigationLink {
                        InterestEditView(
                            interests: Binding(
                                get: { viewModel.profile?.interests ?? [] },
                                set: { viewModel.profile?.interests = $0 }
                            )
                        )
                    } label: {
                        HStack {
                            Text("興味タグ")
                            Spacer()
                            Text("\(viewModel.profile?.interests.count ?? 0)個")
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                } header: {
                    Text("興味")
                } footer: {
                    Text("3〜10個選択してください")
                }

                // 写真セクション
                Section {
                    NavigationLink {
                        PhotoManagementView(
                            viewModel: PhotoManagementViewModel(photos: viewModel.profile?.photos ?? [])
                        )
                    } label: {
                        HStack {
                            Text("写真")
                            Spacer()
                            Text("\(viewModel.profile?.photos.count ?? 0)枚")
                                .foregroundColor(ColorTokens.textSecondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(ColorTokens.textTertiary)
                        }
                    }
                } header: {
                    Text("写真")
                } footer: {
                    Text("1〜5枚登録してください")
                }

                // バリデーションエラー
                if !viewModel.validationErrors.isEmpty {
                    Section {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            Text(error)
                                .font(Typography.footnote)
                                .foregroundColor(ColorTokens.accentDanger)
                        }
                    }
                }
            }
            .navigationTitle("プロフィール編集")
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
                            await viewModel.saveProfile()
                            if viewModel.validationErrors.isEmpty && viewModel.errorMessage == nil {
                                showToast = true
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .overlay(
                Group {
                    if viewModel.isSaving {
                        LoadingView(message: "保存中...")
                    }
                }
            )
        }
        .toast(message: "保存しました", type: .success, isPresented: $showToast)
    }
}

// MARK: - Interest Edit View

struct InterestEditView: View {
    @Binding var interests: [String]
    @Environment(\.dismiss) private var dismiss

    @State private var selectedInterests: Set<String> = []

    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: Spacing.s)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("3〜10個選択してください（\(selectedInterests.count)/10）")
                    .font(Typography.footnote)
                    .foregroundColor(
                        selectedInterests.count >= 3 && selectedInterests.count <= 10
                            ? ColorTokens.accentSuccess
                            : ColorTokens.textSecondary
                    )
                    .padding(.horizontal, Spacing.l)

                LazyVGrid(columns: columns, spacing: Spacing.m) {
                    ForEach(OnboardingViewModel.availableInterests, id: \.self) { interest in
                        InterestChip(
                            title: interest,
                            isSelected: selectedInterests.contains(interest),
                            action: {
                                toggleInterest(interest)
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
            .padding(.vertical, Spacing.l)
        }
        .navigationTitle("興味タグ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完了") {
                    interests = Array(selectedInterests)
                    dismiss()
                }
                .disabled(selectedInterests.count < 3 || selectedInterests.count > 10)
            }
        }
        .onAppear {
            selectedInterests = Set(interests)
        }
    }

    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < 10 {
            selectedInterests.insert(interest)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(
            viewModel: .make(currentUserId: MockData.currentUser.id)
        )
        .previewDisplayName("Profile Edit View")
    }
}
#endif
