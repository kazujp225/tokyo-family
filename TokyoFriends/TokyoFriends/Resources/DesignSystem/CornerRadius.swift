import Foundation

/// デザイントークン: 角丸
/// 3.3 角丸・影・線 - 0.5_デザイン定義.md
enum CornerRadius {

    /// Card = 12pt - カード全般
    static let card: CGFloat = 12

    /// Chip = 10pt - チップ（興味タグ・フィルタ）
    static let chip: CGFloat = 10

    /// Button = 10pt - ボタン
    static let button: CGFloat = 10

    /// Pill = 16pt - ピル形状（バッジ・連続日数）
    static let pill: CGFloat = 16

    /// Thumbnail = 8pt - サムネイル画像
    static let thumbnail: CGFloat = 8

    /// Avatar = 50% - アバター（円形）
    /// Note: SwiftUIでは .clipShape(Circle()) を使用
}

// MARK: - Elevation (Shadow)

enum Elevation {

    /// Elevation 0 - 無影（基本）
    static let zero: CGFloat = 0

    /// Elevation 1 - 強調カード
    /// y offset: 2, blur: 4, opacity: 10–12%
    static let one: (yOffset: CGFloat, blur: CGFloat, opacity: Double) = (2, 4, 0.1)

    /// Elevation 2 - モーダル（ほぼ未使用、Material優先）
    /// y offset: 4, blur: 8, opacity: 15%
    static let two: (yOffset: CGFloat, blur: CGFloat, opacity: Double) = (4, 8, 0.15)
}
