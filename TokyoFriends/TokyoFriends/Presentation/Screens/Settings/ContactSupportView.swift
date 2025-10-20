import SwiftUI

/// お問い合わせ画面
/// デザイン定義: 0.5_デザイン定義.md - 設定画面
struct ContactSupportView: View {

    @Bindable var viewModel: ContactSupportViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // ヘッダー
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(ColorTokens.accentPrimary)

                        Text("お困りですか？")
                            .font(Typography.title2)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("サポートチームがお手伝いします。以下からお問い合わせの種類を選択してください。")
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // お問い合わせ種類
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("お問い合わせ種類")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        Picker("", selection: $viewModel.category) {
                            ForEach(SupportCategory.allCases, id: \.self) { category in
                                Text(category.displayText).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.m)
                        .background(ColorTokens.bgSection)
                        .cornerRadius(CornerRadius.card)
                    }

                    // 件名
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("件名")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        TextField("問題の簡潔な説明", text: $viewModel.subject)
                            .textFieldStyle(.roundedBorder)
                    }

                    // 詳細
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("詳細")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        TextEditor(text: $viewModel.message)
                            .frame(height: 200)
                            .padding(Spacing.s)
                            .background(ColorTokens.bgSection)
                            .cornerRadius(CornerRadius.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.card)
                                    .stroke(ColorTokens.separator, lineWidth: 1)
                            )

                        Text("\(viewModel.message.count)/1000")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // メールアドレス
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("返信先メールアドレス")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        TextField("your@email.com", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    // 添付ファイル
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("添付ファイル（任意）")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        Button {
                            viewModel.showImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(ColorTokens.accentPrimary)
                                Text("スクリーンショットを添付")
                                    .foregroundColor(ColorTokens.accentPrimary)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(ColorTokens.accentPrimary)
                            }
                            .padding(Spacing.m)
                            .background(ColorTokens.bgSection)
                            .cornerRadius(CornerRadius.card)
                        }

                        if !viewModel.attachments.isEmpty {
                            ForEach(viewModel.attachments.indices, id: \.self) { index in
                                HStack {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(ColorTokens.accentPrimary)
                                    Text("image_\(index + 1).jpg")
                                        .font(Typography.footnote)
                                    Spacer()
                                    Button {
                                        viewModel.attachments.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(ColorTokens.textTertiary)
                                    }
                                }
                                .padding(Spacing.s)
                                .background(ColorTokens.bgCard)
                                .cornerRadius(CornerRadius.chip)
                            }
                        }
                    }

                    // よくある質問
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        HStack {
                            Text("よくある質問")
                                .font(Typography.headline)
                                .foregroundColor(ColorTokens.textPrimary)
                            Spacer()
                        }

                        ForEach(viewModel.faqs, id: \.question) { faq in
                            DisclosureGroup {
                                Text(faq.answer)
                                    .font(Typography.footnote)
                                    .foregroundColor(ColorTokens.textSecondary)
                                    .padding(.top, Spacing.s)
                            } label: {
                                Text(faq.question)
                                    .font(Typography.body)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            .padding(Spacing.m)
                            .background(ColorTokens.bgCard)
                            .cornerRadius(CornerRadius.card)
                        }
                    }

                    // 送信ボタン
                    PrimaryButton(
                        title: "送信",
                        action: {
                            Task {
                                await viewModel.submitSupport()
                            }
                        },
                        isLoading: viewModel.isSubmitting,
                        isDisabled: !viewModel.canSubmit
                    )
                    .padding(.top, Spacing.m)
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("お問い合わせ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("送信完了", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("お問い合わせを受け付けました。2営業日以内にメールでご返信いたします。")
            }
        }
    }
}

// MARK: - ViewModel

@Observable
final class ContactSupportViewModel {
    var category: SupportCategory = .technicalIssue
    var subject = ""
    var message = ""
    var email = ""
    var attachments: [String] = []
    var isSubmitting = false
    var showSuccess = false
    var showImagePicker = false

    let faqs: [FAQ] = [
        FAQ(
            question: "マッチが成立しません",
            answer: "マッチは双方がLikeを送った場合に成立します。プロフィールを充実させると、マッチ率が上がります。"
        ),
        FAQ(
            question: "通知が届きません",
            answer: "設定→通知→Tokyo Friendsで通知が許可されているか確認してください。"
        ),
        FAQ(
            question: "アカウントを削除したい",
            answer: "設定→アカウント→アカウント削除から実行できます。削除後14日以内であれば復元可能です。"
        ),
        FAQ(
            question: "不適切なユーザーを見つけた",
            answer: "該当ユーザーのプロフィールから「通報」を選択してください。24時間以内に対応します。"
        )
    ]

    var canSubmit: Bool {
        !subject.isEmpty && !message.isEmpty && !email.isEmpty && message.count <= 1000
    }

    @MainActor
    func submitSupport() async {
        isSubmitting = true

        // TODO: 実際はAPIでサポートリクエストを送信
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        print("サポートリクエスト送信: \(category.displayText) - \(subject)")

        isSubmitting = false
        showSuccess = true
    }
}

// MARK: - Models

enum SupportCategory: String, CaseIterable {
    case technicalIssue = "技術的な問題"
    case accountIssue = "アカウントの問題"
    case reportUser = "ユーザーの通報"
    case featureRequest = "機能リクエスト"
    case billing = "課金・支払い"
    case other = "その他"

    var displayText: String {
        rawValue
    }
}

struct FAQ {
    let question: String
    let answer: String
}

// MARK: - Preview

#if DEBUG
struct ContactSupportView_Previews: PreviewProvider {
    static var previews: some View {
        ContactSupportView(
            viewModel: ContactSupportViewModel()
        )
        .previewDisplayName("Contact Support View")
    }
}
#endif
