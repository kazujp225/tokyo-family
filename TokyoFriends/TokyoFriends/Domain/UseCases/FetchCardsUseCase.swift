import Foundation

/// カード取得ユースケース
/// 機能ID: F-05 - カード探索（0.3_機能定義.md）
/// ビジネスロジック: フィルタ適用、ブロックユーザー除外、スコア計算
final class FetchCardsUseCase {

    // MARK: - Dependencies

    private let cardRepository: CardRepository
    private let userRepository: UserRepository

    // MARK: - Initializer

    init(
        cardRepository: CardRepository,
        userRepository: UserRepository
    ) {
        self.cardRepository = cardRepository
        self.userRepository = userRepository
    }

    // MARK: - Execute

    /// カードデッキを取得
    /// - Parameters:
    ///   - userId: 現在のユーザーID
    ///   - filters: フィルタ条件
    /// - Returns: カードのリスト（ブロックユーザー除外済み、スコア降順）
    func execute(
        userId: UUID,
        filters: CardFilters?
    ) async throws -> [CardModel] {
        // 1. ブロックリストを取得
        let blockedUserIds = try await userRepository.fetchBlockedUsers(userId: userId)

        // 2. カードを取得（自分を除外）
        var cards = try await cardRepository.fetchCards(
            excludeUserId: userId,
            filters: filters
        )

        // 3. ブロックしたユーザーのカードを除外
        cards = cards.filter { card in
            !blockedUserIds.contains(card.userId)
        }

        // 4. スコア降順でソート（リポジトリでも実施しているが念のため）
        cards.sort { $0.totalScore > $1.totalScore }

        return cards
    }
}
