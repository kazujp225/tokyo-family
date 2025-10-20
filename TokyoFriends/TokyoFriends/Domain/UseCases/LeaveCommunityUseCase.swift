import Foundation

/// コミュニティ退出ユースケース
/// 機能ID: F-03 - コミュニティ退出（0.3_機能定義.md）
/// ビジネスロジック: 退出処理
final class LeaveCommunityUseCase {

    // MARK: - Dependencies

    private let communityRepository: CommunityRepository

    // MARK: - Initializer

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    // MARK: - Execute

    /// コミュニティから退出
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - communityId: コミュニティID
    func execute(
        userId: UUID,
        communityId: UUID
    ) async throws {
        // コミュニティから退出
        try await communityRepository.leaveCommunity(
            userId: userId,
            communityId: communityId
        )
    }
}
