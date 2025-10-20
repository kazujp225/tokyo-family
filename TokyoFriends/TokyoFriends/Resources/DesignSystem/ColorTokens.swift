import SwiftUI

/// デザイントークン: カラー
/// 3.1 配色（Semantic Colors優先）- 0.5_デザイン定義.md
enum ColorTokens {

    // MARK: - Background

    /// Bg/Base - 画面全体の背景
    static let bgBase = Color(.systemBackground)

    /// Bg/Section - セクションブロック背景
    static let bgSection = Color(.secondarySystemBackground)

    /// Bg/Card - カード背景
    static let bgCard = Color(.secondarySystemGroupedBackground)

    /// Bg/Elevated - モーダル・シート背景
    static let bgElevated = Color(.tertiarySystemBackground)

    // MARK: - Text

    /// Text/Primary - 主要テキスト（見出し・本文）
    static let textPrimary = Color(.label)

    /// Text/Secondary - 補足テキスト（メタ情報）
    static let textSecondary = Color(.secondaryLabel)

    /// Text/Tertiary - さらに軽微なテキスト
    static let textTertiary = Color(.tertiaryLabel)

    /// Text/Link - リンク・タップ可能テキスト
    static let textLink = Color(.link)

    // MARK: - Accent

    /// Accent/Primary - 主要CTA・選択状態
    static let accentPrimary = Color(.systemBlue)

    /// Accent/Success - 成功トースト・マッチ成立
    static let accentSuccess = Color(.systemGreen)

    /// Accent/Warning - 警告・注意喚起
    static let accentWarning = Color(.systemOrange)

    /// Accent/Danger - エラー・削除・通報
    static let accentDanger = Color(.systemRed)

    // MARK: - Separator

    /// Line/Separator - 薄いライン
    static let lineSeparator = Color(.separator)

    /// Line/Opaque - 不透明ライン
    static let lineOpaque = Color(.opaqueSeparator)

    // MARK: - Material (for background blur effects)

    /// システムマテリアル（半透明・ぼかし）
    /// ナビゲーションバー・タブバーの背景に使用
    static let systemMaterialBackground = Material.regular

    /// シンマテリアル
    /// モーダル・シートの背景に使用
    static let thinMaterialBackground = Material.thin

    /// ウルトラシンマテリアル
    /// より透明度の高いモーダル背景
    static let ultraThinMaterialBackground = Material.ultraThin

    // MARK: - Fill Colors (for backgrounds)

    /// SecondarySystemFill - チップ未選択時の背景
    static let secondarySystemFill = Color(.secondarySystemFill)

    /// TertiarySystemFill - ピル形状の背景
    static let tertiarySystemFill = Color(.tertiarySystemFill)
}

// MARK: - Preview

#if DEBUG
struct ColorTokens_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Background Colors
                ColorRow(title: "Bg/Base", color: ColorTokens.bgBase)
                ColorRow(title: "Bg/Section", color: ColorTokens.bgSection)
                ColorRow(title: "Bg/Card", color: ColorTokens.bgCard)
                ColorRow(title: "Bg/Elevated", color: ColorTokens.bgElevated)

                Divider()

                // Text Colors
                ColorRow(title: "Text/Primary", color: ColorTokens.textPrimary)
                ColorRow(title: "Text/Secondary", color: ColorTokens.textSecondary)
                ColorRow(title: "Text/Tertiary", color: ColorTokens.textTertiary)
                ColorRow(title: "Text/Link", color: ColorTokens.textLink)

                Divider()

                // Accent Colors
                ColorRow(title: "Accent/Primary", color: ColorTokens.accentPrimary)
                ColorRow(title: "Accent/Success", color: ColorTokens.accentSuccess)
                ColorRow(title: "Accent/Warning", color: ColorTokens.accentWarning)
                ColorRow(title: "Accent/Danger", color: ColorTokens.accentDanger)
            }
            .padding()
        }
        .background(ColorTokens.bgBase)
        .preferredColorScheme(.light)
        .previewDisplayName("Light Mode")

        ScrollView {
            VStack(spacing: 16) {
                ColorRow(title: "Bg/Base", color: ColorTokens.bgBase)
                ColorRow(title: "Bg/Section", color: ColorTokens.bgSection)
                ColorRow(title: "Text/Primary", color: ColorTokens.textPrimary)
                ColorRow(title: "Accent/Primary", color: ColorTokens.accentPrimary)
            }
            .padding()
        }
        .background(ColorTokens.bgBase)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }

    struct ColorRow: View {
        let title: String
        let color: Color

        var body: some View {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(ColorTokens.textPrimary)
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(ColorTokens.lineSeparator, lineWidth: 1)
                    )
            }
            .padding(.vertical, 4)
        }
    }
}
#endif
