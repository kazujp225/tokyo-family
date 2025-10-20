import Foundation
import Observation

/// コミュニティ画面ViewModel
/// 画面ID: PG-20, PG-21 - コミュニティ一覧・詳細（0.4_ページ定義.md）
/// MVVM + Observation pattern（iOS 17+）
@Observable
final class CommunityViewModel {

    // MARK: - Published State

    var communities: [Community] = []
    var userCommunities: [Community] = []
    var selectedCommunity: Community?
    var districtFilter: String?
    var interestFilter: String?
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let fetchCommunitiesUseCase: FetchCommunitiesUseCase
    private let joinCommunityUseCase: JoinCommunityUseCase
    private let leaveCommunityUseCase: LeaveCommunityUseCase
    private let currentUserId: UUID

    // MARK: - Computed Properties

    var hasFilters: Bool {
        districtFilter != nil || interestFilter != nil
    }

    // MARK: - Initializer

    init(
        fetchCommunitiesUseCase: FetchCommunitiesUseCase,
        joinCommunityUseCase: JoinCommunityUseCase,
        leaveCommunityUseCase: LeaveCommunityUseCase,
        currentUserId: UUID
    ) {
        self.fetchCommunitiesUseCase = fetchCommunitiesUseCase
        self.joinCommunityUseCase = joinCommunityUseCase
        self.leaveCommunityUseCase = leaveCommunityUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// コミュニティ一覧を読み込み
    @MainActor
    func loadCommunities() async {
        isLoading = true
        errorMessage = nil

        do {
            communities = try await fetchCommunitiesUseCase.execute(
                district: districtFilter,
                interestTag: interestFilter
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// ユーザーが参加中のコミュニティを読み込み
    @MainActor
    func loadUserCommunities() async {
        do {
            userCommunities = try await fetchCommunitiesUseCase.fetchUserCommunities(
                userId: currentUserId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// コミュニティに参加
    @MainActor
    func joinCommunity(_ community: Community) async {
        do {
            try await joinCommunityUseCase.execute(
                userId: currentUserId,
                communityId: community.id
            )

            // 参加後、ユーザーコミュニティを再読み込み
            await loadUserCommunities()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// コミュニティから退出
    @MainActor
    func leaveCommunity(_ community: Community) async {
        do {
            try await leaveCommunityUseCase.execute(
                userId: currentUserId,
                communityId: community.id
            )

            // 退出後、ユーザーコミュニティを再読み込み
            await loadUserCommunities()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// コミュニティ詳細を読み込み
    @MainActor
    func loadCommunityDetail(_ communityId: UUID) async {
        do {
            selectedCommunity = try await fetchCommunitiesUseCase.fetchDetail(
                communityId: communityId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// フィルタを更新して再読み込み
    @MainActor
    func updateFilters(district: String?, interest: String?) async {
        districtFilter = district
        interestFilter = interest
        await loadCommunities()
    }

    /// フィルタをクリア
    @MainActor
    func clearFilters() async {
        districtFilter = nil
        interestFilter = nil
        await loadCommunities()
    }

    /// ユーザーがコミュニティに参加しているか確認
    func isJoined(_ community: Community) -> Bool {
        userCommunities.contains(where: { $0.id == community.id })
    }
}

// MARK: - Factory

extension CommunityViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> CommunityViewModel {
        let provider = RepositoryProvider.shared

        let fetchCommunitiesUseCase = FetchCommunitiesUseCase(
            communityRepository: provider.communityRepository
        )

        let joinCommunityUseCase = JoinCommunityUseCase(
            communityRepository: provider.communityRepository
        )

        let leaveCommunityUseCase = LeaveCommunityUseCase(
            communityRepository: provider.communityRepository
        )

        return CommunityViewModel(
            fetchCommunitiesUseCase: fetchCommunitiesUseCase,
            joinCommunityUseCase: joinCommunityUseCase,
            leaveCommunityUseCase: leaveCommunityUseCase,
            currentUserId: currentUserId
        )
    }
}
