import Foundation
import Observation

/// ホーム画面ViewModel
/// 画面ID: PG-10 - ホーム（0.4_ページ定義.md）
/// MVVM + Observation pattern（iOS 17+）
@Observable
final class HomeViewModel {

    // MARK: - Published State

    var recommendedCards: [CardModel] = []
    var userCommunities: [Community] = []
    var recentMatches: [Match] = []
    var currentUser: User?
    var currentProfile: Profile?
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let fetchCardsUseCase: FetchCardsUseCase
    private let fetchCommunitiesUseCase: FetchCommunitiesUseCase
    private let fetchMatchesUseCase: FetchMatchesUseCase
    private let userRepository: UserRepository
    private let profileRepository: ProfileRepository
    private let currentUserId: UUID

    // MARK: - Computed Properties

    var hasRecommendations: Bool {
        !recommendedCards.isEmpty
    }

    var hasMatches: Bool {
        !recentMatches.isEmpty
    }

    var hasCommunities: Bool {
        !userCommunities.isEmpty
    }

    // MARK: - Initializer

    init(
        fetchCardsUseCase: FetchCardsUseCase,
        fetchCommunitiesUseCase: FetchCommunitiesUseCase,
        fetchMatchesUseCase: FetchMatchesUseCase,
        userRepository: UserRepository,
        profileRepository: ProfileRepository,
        currentUserId: UUID
    ) {
        self.fetchCardsUseCase = fetchCardsUseCase
        self.fetchCommunitiesUseCase = fetchCommunitiesUseCase
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.userRepository = userRepository
        self.profileRepository = profileRepository
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// ホーム画面のデータを読み込み
    @MainActor
    func loadHomeData() async {
        isLoading = true
        errorMessage = nil

        async let user = loadCurrentUser()
        async let profile = loadCurrentProfile()
        async let cards = loadRecommendedCards()
        async let communities = loadUserCommunities()
        async let matches = loadRecentMatches()

        // 並行実行
        _ = await (user, profile, cards, communities, matches)

        isLoading = false
    }

    // MARK: - Private Loaders

    @MainActor
    private func loadCurrentUser() async {
        do {
            currentUser = try await userRepository.fetchUser(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadCurrentProfile() async {
        do {
            currentProfile = try await profileRepository.fetchProfile(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadRecommendedCards() async {
        do {
            // トップ3枚のみ取得
            let cards = try await fetchCardsUseCase.execute(
                userId: currentUserId,
                filters: nil
            )
            recommendedCards = Array(cards.prefix(3))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadUserCommunities() async {
        do {
            // トップ5件のみ取得
            let communities = try await fetchCommunitiesUseCase.fetchUserCommunities(
                userId: currentUserId
            )
            userCommunities = Array(communities.prefix(5))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadRecentMatches() async {
        do {
            // 最新3件のみ取得
            let matches = try await fetchMatchesUseCase.execute(userId: currentUserId)
            recentMatches = Array(matches.prefix(3))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Factory

extension HomeViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> HomeViewModel {
        let provider = RepositoryProvider.shared

        let fetchCardsUseCase = FetchCardsUseCase(
            cardRepository: provider.cardRepository,
            userRepository: provider.userRepository
        )

        let fetchCommunitiesUseCase = FetchCommunitiesUseCase(
            communityRepository: provider.communityRepository
        )

        let fetchMatchesUseCase = FetchMatchesUseCase(
            matchRepository: provider.matchRepository
        )

        return HomeViewModel(
            fetchCardsUseCase: fetchCardsUseCase,
            fetchCommunitiesUseCase: fetchCommunitiesUseCase,
            fetchMatchesUseCase: fetchMatchesUseCase,
            userRepository: provider.userRepository,
            profileRepository: provider.profileRepository,
            currentUserId: currentUserId
        )
    }
}
