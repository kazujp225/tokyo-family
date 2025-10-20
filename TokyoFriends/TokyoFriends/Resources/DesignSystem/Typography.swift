import SwiftUI

/// デザイントークン: タイポグラフィ
/// 3.2 文字（Dynamic Type準拠）- 0.5_デザイン定義.md
enum Typography {

    // MARK: - Text Styles (Dynamic Type準拠)

    /// 大見出し - Large Title（34pt Bold）
    static let largeTitle = Font.largeTitle.weight(.bold)

    /// セクション見出し - Title 2（22pt Semibold）
    static let title2 = Font.title2.weight(.semibold)

    /// カードタイトル - Headline（17pt Semibold）
    static let headline = Font.headline

    /// 本文 - Body（17pt Regular）
    static let body = Font.body

    /// 補足・メタ - Footnote（13pt Regular）
    static let footnote = Font.footnote

    /// ボタン - Callout（16pt Medium）
    static let callout = Font.callout.weight(.medium)

    /// キャプション - Caption 1（12pt Regular）
    static let caption = Font.caption

    // MARK: - Line Spacing

    /// 行間: 120–130%
    /// SwiftUIはDynamic Typeで自動調整されるが、カスタム調整が必要な場合に使用
    static let lineSpacing: CGFloat = 4 // Bodyサイズ17ptの約20–25%

    /// 段落間: 文字サイズ × 0.5〜0.75
    static let paragraphSpacing: CGFloat = 8.5 // Bodyサイズ17ptの50%
}

// MARK: - Text Style Extensions

extension Text {
    /// Large Title スタイルを適用
    func largeTitle() -> some View {
        self.font(Typography.largeTitle)
            .foregroundColor(ColorTokens.textPrimary)
    }

    /// Title 2 スタイルを適用
    func title2() -> some View {
        self.font(Typography.title2)
            .foregroundColor(ColorTokens.textPrimary)
    }

    /// Headline スタイルを適用
    func headline() -> some View {
        self.font(Typography.headline)
            .foregroundColor(ColorTokens.textPrimary)
    }

    /// Body スタイルを適用
    func body() -> some View {
        self.font(Typography.body)
            .foregroundColor(ColorTokens.textPrimary)
            .lineSpacing(Typography.lineSpacing)
    }

    /// Footnote スタイルを適用
    func footnote() -> some View {
        self.font(Typography.footnote)
            .foregroundColor(ColorTokens.textSecondary)
    }

    /// Callout スタイルを適用（ボタン用）
    func callout() -> some View {
        self.font(Typography.callout)
            .foregroundColor(ColorTokens.textPrimary)
    }

    /// Caption スタイルを適用
    func caption() -> some View {
        self.font(Typography.caption)
            .foregroundColor(ColorTokens.textTertiary)
    }
}

// MARK: - Preview

#if DEBUG
struct Typography_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Large Title")
                    .largeTitle()

                Text("Title 2 - セクション見出し")
                    .title2()

                Text("Headline - カードタイトル")
                    .headline()

                Text("Body - 本文テキストです。週末カフェ巡りが好きです。サウナと写真も趣味です。")
                    .body()

                Text("Footnote - 補足情報")
                    .footnote()

                Text("Callout - ボタンテキスト")
                    .callout()

                Text("Caption - キャプション")
                    .caption()
            }
            .padding()
        }
        .background(ColorTokens.bgBase)
        .preferredColorScheme(.light)
        .previewDisplayName("Light Mode")

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Large Title")
                    .largeTitle()

                Text("Body - 本文テキスト")
                    .body()
            }
            .padding()
        }
        .background(ColorTokens.bgBase)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif
