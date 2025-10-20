import Foundation

/// カード探索リポジトリプロトコル
/// 機能ID: F-05 - カード探索（0.3_機能定義.md）
protocol CardRepository {

    /// カードデッキを取得
    /// - Parameters:
    ///   - userId: 現在のユーザーID（除外用）
    ///   - filters: フィルタ条件（地域・年齢・属性・興味）
    /// - Returns: カードのリスト（スコア降順）
    func fetchCards(
        excludeUserId userId: UUID,
        filters: CardFilters?
    ) async throws -> [CardModel]

    /// カードの詳細情報を取得
    /// - Parameter cardUserId: カードのユーザーID
    /// - Returns: プロフィール詳細
    func fetchCardDetail(cardUserId: UUID) async throws -> Profile
}

// MARK: - Filter Models

/// カードフィルタ条件
struct CardFilters: Equatable {
    /// 地域フィルタ（複数選択可）
    var districts: [String]?

    /// 年齢範囲フィルタ（複数選択可）
    var ageRanges: [AgeRange]?

    /// 属性フィルタ（学生 or 社会人 or 両方）
    var attributes: [Attribute]?

    /// 興味タグフィルタ（複数選択可）
    var interests: [String]?

    /// フィルタが空かどうか
    var isEmpty: Bool {
        districts == nil && ageRanges == nil && attributes == nil && interests == nil
    }
}

// MARK: - Repository Errors

/// リポジトリエラー
enum RepositoryError: Error, LocalizedError {
    case networkError
    case notFound
    case unauthorized
    case invalidData
    case serverError(message: String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "ネットワーク接続に失敗しました"
        case .notFound:
            return "データが見つかりません"
        case .unauthorized:
            return "認証に失敗しました"
        case .invalidData:
            return "データが不正です"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        }
    }
}
