import Foundation

/// コミュニティ一覧取得ユースケース
/// 機能ID: F-03 - コミュニティ一覧（0.3_機能定義.md）
/// ビジネスロジック: フィルタ適用、参加者数順ソート
final class FetchCommunitiesUseCase {

    // MARK: - Dependencies

    private let communityRepository: CommunityRepository

    // MARK: - Initializer

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    // MARK: - Execute

    /// コミュニティ一覧を取得
    /// - Parameters:
    ///   - district: 地域フィルタ（nilは全地域）
    ///   - interestTag: 興味タグフィルタ（nilは全タグ）
    /// - Returns: コミュニティのリスト（参加者数降順）
    func execute(
        district: String?,
        interestTag: String?
    ) async throws -> [Community] {
        let communities = try await communityRepository.fetchCommunities(
            district: district,
            interestTag: interestTag
        )

        return communities
    }

    /// ユーザーが参加中のコミュニティを取得
    /// - Parameter userId: ユーザーID
    /// - Returns: 参加中のコミュニティリスト
    func fetchUserCommunities(userId: UUID) async throws -> [Community] {
        let communities = try await communityRepository.fetchUserCommunities(userId: userId)
        return communities
    }

    /// コミュニティの詳細を取得
    /// - Parameter communityId: コミュニティID
    /// - Returns: コミュニティ詳細
    func fetchDetail(communityId: UUID) async throws -> Community {
        let community = try await communityRepository.fetchCommunityDetail(communityId: communityId)
        return community
    }
}
