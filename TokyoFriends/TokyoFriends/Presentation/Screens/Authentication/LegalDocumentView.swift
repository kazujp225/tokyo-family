import SwiftUI

/// 法的文書表示画面
/// - 利用規約
/// - プライバシーポリシー
struct LegalDocumentView: View {

    let documentType: LegalDocumentType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // ヘッダー
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text(documentType.title)
                            .font(Typography.largeTitle)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("最終更新日: 2025年10月20日")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textTertiary)
                    }

                    // 文書内容
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        ForEach(documentType.sections, id: \.title) { section in
                            sectionView(section)
                        }
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

    private func sectionView(_ section: LegalSection) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(section.title)
                .font(Typography.title3)
                .foregroundColor(ColorTokens.textPrimary)

            ForEach(section.paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !section.bulletPoints.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    ForEach(section.bulletPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: Spacing.s) {
                            Text("•")
                                .foregroundColor(ColorTokens.textSecondary)
                            Text(point)
                                .font(Typography.body)
                                .foregroundColor(ColorTokens.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(Spacing.m)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
    }
}

// MARK: - Models

enum LegalDocumentType {
    case termsOfService
    case privacyPolicy

    var title: String {
        switch self {
        case .termsOfService:
            return "利用規約"
        case .privacyPolicy:
            return "プライバシーポリシー"
        }
    }

    var sections: [LegalSection] {
        switch self {
        case .termsOfService:
            return termsOfServiceSections
        case .privacyPolicy:
            return privacyPolicySections
        }
    }

    private var termsOfServiceSections: [LegalSection] {
        [
            LegalSection(
                title: "1. サービス概要",
                paragraphs: [
                    "Tokyo Friends（以下「本サービス」）は、東京在住の18歳以上の方を対象とした友達作り・交流支援サービスです。",
                    "本サービスは、コミュニティ参加型のマッチング機能を通じて、安全で健全な友人関係の構築をサポートします。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "2. 利用資格",
                paragraphs: [
                    "本サービスを利用するには、以下の条件を満たす必要があります："
                ],
                bulletPoints: [
                    "18歳以上であること",
                    "東京都内に居住または活動拠点があること",
                    "真実かつ正確な情報を登録すること",
                    "他者の権利を侵害しないこと"
                ]
            ),
            LegalSection(
                title: "3. 禁止事項",
                paragraphs: [
                    "以下の行為を禁止します。違反した場合、アカウント停止または削除の対象となります。"
                ],
                bulletPoints: [
                    "虚偽の情報の登録",
                    "商業目的の利用",
                    "ハラスメント行為",
                    "他者へのなりすまし",
                    "不適切な写真やコンテンツの投稿",
                    "個人情報の不正取得",
                    "18歳未満の利用"
                ]
            ),
            LegalSection(
                title: "4. プライバシーとデータ保護",
                paragraphs: [
                    "本サービスは、GDPRおよび個人情報保護法に準拠したデータ保護を実施しています。",
                    "詳細は「プライバシーポリシー」をご確認ください。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "5. 免責事項",
                paragraphs: [
                    "本サービスは、ユーザー間のトラブルについて一切の責任を負いません。",
                    "安全な利用のため、初対面時は公共の場所での会合を推奨します。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "6. サービスの変更・中断",
                paragraphs: [
                    "運営者は、事前の通知なくサービス内容の変更、一時中断、または終了を行う権利を有します。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "7. 準拠法と管轄裁判所",
                paragraphs: [
                    "本規約は日本法に準拠し、本サービスに関する紛争は東京地方裁判所を専属的合意管轄裁判所とします。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "8. お問い合わせ",
                paragraphs: [
                    "本規約に関するご質問は、アプリ内「お問い合わせ」フォームからご連絡ください。"
                ],
                bulletPoints: []
            )
        ]
    }

    private var privacyPolicySections: [LegalSection] {
        [
            LegalSection(
                title: "1. 収集する情報",
                paragraphs: [
                    "Tokyo Friendsは、以下の情報を収集します："
                ],
                bulletPoints: [
                    "基本情報：年齢範囲、属性（学生/社会人）、学校名・勤務先",
                    "地域情報：区、最寄り駅",
                    "プロフィール情報：写真、自己紹介、興味タグ",
                    "SNS情報：Instagramハンドル（任意）",
                    "利用情報：Like/Skip履歴、マッチ履歴、コミュニティ参加状況",
                    "デバイス情報：OS、デバイスID、IPアドレス",
                    "位置情報：大まかな地域（区レベル）のみ"
                ]
            ),
            LegalSection(
                title: "2. 情報の利用目的",
                paragraphs: [
                    "収集した情報は以下の目的で利用します："
                ],
                bulletPoints: [
                    "マッチング機能の提供",
                    "おすすめユーザー・コミュニティの表示",
                    "サービス品質の向上",
                    "不正利用の防止",
                    "カスタマーサポート",
                    "統計分析（匿名化データ）"
                ]
            ),
            LegalSection(
                title: "3. 情報の第三者提供",
                paragraphs: [
                    "以下の場合を除き、第三者への情報提供は行いません："
                ],
                bulletPoints: [
                    "ユーザーの同意がある場合",
                    "法令に基づく開示要求がある場合",
                    "人の生命・身体・財産の保護に必要な場合",
                    "サービス運営に必要な範囲で業務委託先に提供する場合（秘密保持契約あり）"
                ]
            ),
            LegalSection(
                title: "4. Cookieと追跡技術",
                paragraphs: [
                    "本サービスは、以下の技術を使用します："
                ],
                bulletPoints: [
                    "セッション管理のためのCookie",
                    "分析ツール（匿名化データのみ）",
                    "クラッシュレポート"
                ]
            ),
            LegalSection(
                title: "5. データの保管とセキュリティ",
                paragraphs: [
                    "ユーザーデータは、業界標準のセキュリティ対策を施したサーバーに保管されます。",
                    "通信は全てTLS/SSL暗号化されます。",
                    "パスワードはハッシュ化され、平文では保存されません。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "6. ユーザーの権利",
                paragraphs: [
                    "GDPRおよび個人情報保護法に基づき、以下の権利があります："
                ],
                bulletPoints: [
                    "データへのアクセス権（データダウンロード）",
                    "データの訂正・削除権",
                    "処理の制限権",
                    "データポータビリティ権",
                    "プロファイリングへの異議申立権"
                ]
            ),
            LegalSection(
                title: "7. データ削除",
                paragraphs: [
                    "アカウント削除時、以下のデータが削除されます：",
                    "プロフィール情報、写真、マッチ履歴、コミュニティ参加履歴。",
                    "削除後14日間はアカウント復元が可能です。14日経過後は完全削除され、復元不可能となります。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "8. 未成年者の保護",
                paragraphs: [
                    "本サービスは18歳未満の利用を禁止しています。",
                    "未成年者のデータを故意に収集することはありません。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "9. プライバシーポリシーの変更",
                paragraphs: [
                    "本ポリシーは、必要に応じて更新される場合があります。",
                    "重要な変更がある場合は、アプリ内通知およびメールでお知らせします。"
                ],
                bulletPoints: []
            ),
            LegalSection(
                title: "10. お問い合わせ",
                paragraphs: [
                    "プライバシーに関するご質問・ご要望は、アプリ内「お問い合わせ」フォームまたは以下のメールアドレスまでご連絡ください。",
                    "Email: privacy@tokyofriends.app"
                ],
                bulletPoints: []
            )
        ]
    }
}

struct LegalSection {
    let title: String
    let paragraphs: [String]
    let bulletPoints: [String]
}

// MARK: - Preview

#if DEBUG
struct LegalDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LegalDocumentView(documentType: .termsOfService)
                .previewDisplayName("Terms of Service")

            LegalDocumentView(documentType: .privacyPolicy)
                .previewDisplayName("Privacy Policy")
        }
    }
}
#endif
