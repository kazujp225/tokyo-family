import Foundation

/// カードリポジトリのモック実装
/// テスト・開発用（MockDataを使用）
final class MockCardRepository: CardRepository {

    // MARK: - Private Properties

    /// モックデータのカード一覧（キャッシュ）
    private var cachedCards: [CardModel] = []

    // MARK: - Initializer

    init() {
        // 初期化時にカードを生成（currentUserを除外）
        self.cachedCards = MockData.generateCards(excludeUserId: MockData.currentUser.id)
    }

    // MARK: - CardRepository

    func fetchCards(
        excludeUserId userId: UUID,
        filters: CardFilters?
    ) async throws -> [CardModel] {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        // カード生成（指定ユーザーを除外）
        var cards = MockData.generateCards(excludeUserId: userId)

        // フィルタ適用
        if let filters = filters, !filters.isEmpty {
            cards = applyFilters(to: cards, filters: filters)
        }

        // スコア降順でソート
        cards.sort { $0.totalScore > $1.totalScore }

        return cards
    }

    func fetchCardDetail(cardUserId: UUID) async throws -> Profile {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        // プロフィールを検索
        guard let profile = MockData.profiles.first(where: { $0.userId == cardUserId }) else {
            throw RepositoryError.notFound
        }

        return profile
    }

    // MARK: - Private Helpers

    /// フィルタを適用
    private func applyFilters(to cards: [CardModel], filters: CardFilters) -> [CardModel] {
        cards.filter { card in
            var matches = true

            // 地域フィルタ
            if let districts = filters.districts, !districts.isEmpty {
                matches = matches && districts.contains(card.profile.district)
            }

            // 年齢範囲フィルタ
            if let ageRanges = filters.ageRanges, !ageRanges.isEmpty {
                matches = matches && ageRanges.contains(card.profile.ageRange)
            }

            // 属性フィルタ
            if let attributes = filters.attributes, !attributes.isEmpty {
                matches = matches && attributes.contains(card.profile.attribute)
            }

            // 興味タグフィルタ（1つ以上一致）
            if let interests = filters.interests, !interests.isEmpty {
                let commonInterests = Set(card.profile.interests).intersection(Set(interests))
                matches = matches && !commonInterests.isEmpty
            }

            return matches
        }
    }
}
