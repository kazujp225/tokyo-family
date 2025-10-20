import SwiftUI

/// ユーザー通報画面
/// デザイン定義: 0.5_デザイン定義.md - 安全機能
struct ReportUserView: View {

    let reportedUserId: UUID
    let reportedUserName: String
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason: ReportReason?
    @State private var additionalDetails = ""
    @State private var isSubmitting = false
    @State private var showSuccessMessage = false
    @State private var showError = false
    @State private var errorMessage = ""

    enum ReportReason: String, CaseIterable, Identifiable {
        case inappropriate = "不適切なコンテンツ"
        case harassment = "嫌がらせ"
        case spam = "スパム"
        case fake = "偽アカウント"
        case underage = "18歳未満"
        case other = "その他"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .inappropriate:
                return "不適切な写真や自己紹介文"
            case .harassment:
                return "脅迫や嫌がらせ行為"
            case .spam:
                return "宣伝や勧誘行為"
            case .fake:
                return "なりすましや虚偽の情報"
            case .underage:
                return "18歳未満の疑い"
            case .other:
                return "その他の問題"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 説明
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("問題を報告")
                            .font(Typography.title2)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("以下のユーザーを報告します：\(reportedUserName)\n\n問題の内容を選択してください。運営チームが確認し、適切な対応を行います。")
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()

                    // 理由選択
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("報告理由")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        ForEach(ReportReason.allCases) { reason in
                            reasonButton(reason)
                        }
                    }

                    // 詳細入力
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("詳細（任意）")
                            .font(Typography.headline)
                            .foregroundColor(ColorTokens.textPrimary)

                        TextEditor(text: $additionalDetails)
                            .frame(height: 120)
                            .padding(Spacing.s)
                            .background(ColorTokens.bgSection)
                            .cornerRadius(CornerRadius.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.card)
                                    .stroke(ColorTokens.separator, lineWidth: 1)
                            )

                        Text("\(additionalDetails.count)/500")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // 注意事項
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        HStack(alignment: .top, spacing: Spacing.s) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(ColorTokens.accentPrimary)

                            Text("虚偽の報告は利用規約違反となります。正確な情報をご提供ください。")
                                .font(Typography.footnote)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .padding(Spacing.m)
                    .background(ColorTokens.accentPrimary.opacity(0.1))
                    .cornerRadius(CornerRadius.card)
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("送信") {
                        Task {
                            await submitReport()
                        }
                    }
                    .disabled(selectedReason == nil || isSubmitting)
                    .opacity(selectedReason == nil ? 0.5 : 1.0)
                }
            }
            .overlay {
                if isSubmitting {
                    LoadingView(message: "送信中...")
                }
            }
            .alert("送信完了", isPresented: $showSuccessMessage) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("報告を受け付けました。運営チームが確認いたします。")
            }
            .alert("エラー", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Reason Button

    private func reasonButton(_ reason: ReportReason) -> some View {
        Button(action: {
            selectedReason = reason
        }) {
            HStack(spacing: Spacing.m) {
                // チェックマーク
                Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedReason == reason ? ColorTokens.accentPrimary : ColorTokens.textTertiary)
                    .font(.title3)

                // 理由
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(reason.rawValue)
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text(reason.description)
                        .font(Typography.caption)
                        .foregroundColor(ColorTokens.textSecondary)
                }

                Spacer()
            }
            .padding(Spacing.m)
            .background(
                selectedReason == reason
                    ? ColorTokens.accentPrimary.opacity(0.1)
                    : ColorTokens.bgCard
            )
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(
                        selectedReason == reason
                            ? ColorTokens.accentPrimary
                            : ColorTokens.separator,
                        lineWidth: selectedReason == reason ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Submit Report

    @MainActor
    private func submitReport() async {
        guard let reason = selectedReason else { return }

        // 文字数制限チェック
        if additionalDetails.count > 500 {
            errorMessage = "詳細は500文字以内で入力してください"
            showError = true
            return
        }

        isSubmitting = true

        // API呼び出しをシミュレート
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒

            // In real app: call ReportRepository
            // try await reportRepository.submitReport(
            //     reportedUserId: reportedUserId,
            //     reason: reason.rawValue,
            //     details: additionalDetails
            // )

            print("Report submitted: User \(reportedUserId), Reason: \(reason.rawValue), Details: \(additionalDetails)")

            isSubmitting = false
            showSuccessMessage = true
        } catch {
            isSubmitting = false
            errorMessage = "送信に失敗しました。もう一度お試しください。"
            showError = true
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ReportUserView_Previews: PreviewProvider {
    static var previews: some View {
        ReportUserView(
            reportedUserId: UUID(),
            reportedUserName: "テストユーザー"
        )
        .previewDisplayName("Report User View")
    }
}
#endif
