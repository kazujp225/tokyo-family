import Foundation

/// コミュニティ参加ユースケース
/// 機能ID: F-03 - コミュニティ参加（0.3_機能定義.md）
/// ビジネスロジック: 参加可能性チェック、参加処理
final class JoinCommunityUseCase {

    // MARK: - Dependencies

    private let communityRepository: CommunityRepository

    // MARK: - Initializer

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    // MARK: - Execute

    /// コミュニティに参加
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - communityId: コミュニティID
    /// - Throws: 既に参加済みの場合はエラー（リポジトリ側で処理）
    func execute(
        userId: UUID,
        communityId: UUID
    ) async throws {
        // 1. コミュニティに参加
        try await communityRepository.joinCommunity(
            userId: userId,
            communityId: communityId
        )

        // 2. 参加後、コミュニティの最新情報を取得（参加者数更新のため）
        _ = try? await communityRepository.fetchCommunityDetail(communityId: communityId)
    }
}
