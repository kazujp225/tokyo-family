import Foundation
import Observation

/// 探索画面ViewModel
/// 画面ID: PG-30 - カード探索（0.4_ページ定義.md）
/// MVVM + Observation pattern（iOS 17+）
@Observable
final class ExploreViewModel {

    // MARK: - Published State

    var cards: [CardModel] = []
    var currentCardIndex: Int = 0
    var filters: CardFilters?
    var isLoading: Bool = false
    var error: Error?
    var errorMessage: String?
    var showMatchSheet: Bool = false
    var newMatch: Match?

    // MARK: - Dependencies

    private let fetchCardsUseCase: FetchCardsUseCase
    private let sendLikeUseCase: SendLikeUseCase
    private let matchRepository: MatchRepository
    private let currentUserId: UUID

    // MARK: - Computed Properties

    var currentCard: CardModel? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }

    var hasMoreCards: Bool {
        currentCardIndex < cards.count
    }

    // MARK: - Initializer

    init(
        fetchCardsUseCase: FetchCardsUseCase,
        sendLikeUseCase: SendLikeUseCase,
        matchRepository: MatchRepository,
        currentUserId: UUID
    ) {
        self.fetchCardsUseCase = fetchCardsUseCase
        self.sendLikeUseCase = sendLikeUseCase
        self.matchRepository = matchRepository
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// カードデッキを読み込み
    @MainActor
    func loadCards() async {
        isLoading = true
        error = nil
        errorMessage = nil

        do {
            cards = try await fetchCardsUseCase.execute(
                userId: currentUserId,
                filters: filters
            )
            currentCardIndex = 0
        } catch let loadError {
            self.error = loadError
            errorMessage = loadError.localizedDescription
        }

        isLoading = false
    }

    /// Likeを送信（右スワイプ）
    @MainActor
    func sendLike() async {
        guard let card = currentCard else { return }

        do {
            let match = try await sendLikeUseCase.execute(
                from: currentUserId,
                to: card.userId
            )

            // マッチング成立の場合はシートを表示
            if let match = match {
                newMatch = match
                showMatchSheet = true
            }

            // 次のカードへ
            moveToNextCard()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Skip（左スワイプ）
    @MainActor
    func skip() async {
        guard let card = currentCard else { return }

        do {
            try await matchRepository.recordSkip(
                userId: currentUserId,
                skippedUserId: card.userId
            )

            // 次のカードへ
            moveToNextCard()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// フィルタを更新して再読み込み
    @MainActor
    func updateFilters(_ newFilters: CardFilters?) async {
        filters = newFilters
        await loadCards()
    }

    /// マッチシートを閉じる
    func dismissMatchSheet() {
        showMatchSheet = false
        newMatch = nil
    }

    // MARK: - Private Helpers

    private func moveToNextCard() {
        currentCardIndex += 1

        // カードが残り少なくなったら追加読み込み（無限スクロール）
        if currentCardIndex >= cards.count - 3 {
            Task { @MainActor in
                await loadCards()
            }
        }
    }
}

// MARK: - Factory

extension ExploreViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> ExploreViewModel {
        let provider = RepositoryProvider.shared

        let fetchCardsUseCase = FetchCardsUseCase(
            cardRepository: provider.cardRepository,
            userRepository: provider.userRepository
        )

        let sendLikeUseCase = SendLikeUseCase(
            matchRepository: provider.matchRepository,
            userRepository: provider.userRepository
        )

        return ExploreViewModel(
            fetchCardsUseCase: fetchCardsUseCase,
            sendLikeUseCase: sendLikeUseCase,
            matchRepository: provider.matchRepository,
            currentUserId: currentUserId
        )
    }
}
