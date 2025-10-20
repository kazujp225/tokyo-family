import Foundation

/// コミュニティリポジトリプロトコル
/// 機能ID: F-03 - コミュニティ参加/退出（0.3_機能定義.md）
protocol CommunityRepository {

    /// コミュニティ一覧を取得
    /// - Parameters:
    ///   - district: 地域フィルタ（nilは全地域）
    ///   - interestTag: 興味タグフィルタ（nilは全タグ）
    /// - Returns: コミュニティのリスト（参加者数降順）
    func fetchCommunities(
        district: String?,
        interestTag: String?
    ) async throws -> [Community]

    /// コミュニティに参加
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - communityId: コミュニティID
    /// - Throws: 既に参加済みの場合は何もしない
    func joinCommunity(
        userId: UUID,
        communityId: UUID
    ) async throws

    /// コミュニティから退出
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - communityId: コミュニティID
    /// - Throws: 参加していない場合は何もしない
    func leaveCommunity(
        userId: UUID,
        communityId: UUID
    ) async throws

    /// ユーザーが参加しているコミュニティを取得
    /// - Parameter userId: ユーザーID
    /// - Returns: 参加中のコミュニティリスト
    func fetchUserCommunities(userId: UUID) async throws -> [Community]

    /// コミュニティの詳細を取得
    /// - Parameter communityId: コミュニティID
    /// - Returns: コミュニティ詳細（参加者数含む）
    func fetchCommunityDetail(communityId: UUID) async throws -> Community
}
