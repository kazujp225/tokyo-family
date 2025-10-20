import Foundation

/// コミュニティリポジトリのモック実装
/// テスト・開発用（MockDataを使用）
final class MockCommunityRepository: CommunityRepository {

    // MARK: - Private Properties

    /// ユーザーごとの参加コミュニティID（モック用状態管理）
    private var userCommunities: [UUID: Set<UUID>] = [:]

    // MARK: - CommunityRepository

    func fetchCommunities(
        district: String?,
        interestTag: String?
    ) async throws -> [Community] {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4秒

        var communities = MockData.communities

        // 地域フィルタ
        if let district = district {
            communities = communities.filter { $0.district == district }
        }

        // 興味タグフィルタ
        if let interestTag = interestTag {
            communities = communities.filter { $0.interestTag == interestTag }
        }

        // 参加者数降順でソート
        communities.sort { $0.participantCount > $1.participantCount }

        return communities
    }

    func joinCommunity(
        userId: UUID,
        communityId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        // コミュニティが存在するか確認
        guard MockData.communities.contains(where: { $0.id == communityId }) else {
            throw RepositoryError.notFound
        }

        // 既に参加済みかチェック
        if var communities = userCommunities[userId] {
            communities.insert(communityId)
            userCommunities[userId] = communities
        } else {
            userCommunities[userId] = [communityId]
        }
    }

    func leaveCommunity(
        userId: UUID,
        communityId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        // 参加していない場合は何もしない
        guard var communities = userCommunities[userId] else {
            return
        }

        communities.remove(communityId)
        userCommunities[userId] = communities
    }

    func fetchUserCommunities(userId: UUID) async throws -> [Community] {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        guard let communityIds = userCommunities[userId] else {
            return []
        }

        return MockData.communities.filter { communityIds.contains($0.id) }
    }

    func fetchCommunityDetail(communityId: UUID) async throws -> Community {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        guard let community = MockData.communities.first(where: { $0.id == communityId }) else {
            throw RepositoryError.notFound
        }

        return community
    }
}
