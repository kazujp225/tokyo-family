import Foundation

/// デザイントークン: 余白スケール（4ptグリッド）
/// 3.4 余白スケール - 0.5_デザイン定義.md
enum Spacing {

    /// XS = 4pt - 極小（アイコンと文字の間）
    static let xs: CGFloat = 4

    /// S = 8pt - 小（要素間の密な間隔）
    static let s: CGFloat = 8

    /// M = 12pt - 中（カード内の要素間）
    static let m: CGFloat = 12

    /// L = 16pt - 大（画面左右のセーフマージン、カード外枠）
    static let l: CGFloat = 16

    /// XL = 24pt - 特大（セクション間）
    static let xl: CGFloat = 24

    /// XXL = 32pt - 超特大（大きなセクション間）
    static let xxl: CGFloat = 32
}

// MARK: - Usage Examples

/*
 使用例:

 // カード内の要素間
 VStack(spacing: Spacing.m) { ... }

 // 画面左右のマージン
 .padding(.horizontal, Spacing.l)

 // セクション間
 .padding(.vertical, Spacing.xl)
 */
