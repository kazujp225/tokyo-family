import Foundation

/// ユーザーリポジトリのモック実装
/// テスト・開発用（MockDataを使用）
final class MockUserRepository: UserRepository {

    // MARK: - Private Properties

    /// ユーザーストレージ（userId -> User）
    private var users: [UUID: User] = [:]

    /// ブロックリスト（blockingUserId -> Set<blockedUserId>）
    private var blockedUsers: [UUID: Set<UUID>] = [:]

    /// 通報履歴（reportingUserId -> [(reportedUserId, reason, details)]）
    private var reports: [UUID: [(UUID, ReportReason, String?)]] = [:]

    // MARK: - Initializer

    init() {
        // モックデータを初期ロード
        for user in MockData.users {
            users[user.id] = user
        }
    }

    // MARK: - UserRepository

    func fetchUser(userId: UUID) async throws -> User {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        guard let user = users[userId] else {
            throw RepositoryError.notFound
        }

        return user
    }

    func createUser(
        authMethod: AuthMethod,
        isOver18: Bool
    ) async throws -> User {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        // 18歳以上チェック
        guard isOver18 else {
            throw RepositoryError.unauthorized
        }

        // 新規ユーザーを作成
        let newUser = User(
            id: UUID(),
            authMethod: authMethod,
            status: .active
        )

        users[newUser.id] = newUser

        return newUser
    }

    func blockUser(
        blockingUserId: UUID,
        blockedUserId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        // ブロック対象が存在するか確認
        guard users[blockedUserId] != nil else {
            throw RepositoryError.notFound
        }

        // ブロックリストに追加
        if blockedUsers[blockingUserId] != nil {
            blockedUsers[blockingUserId]?.insert(blockedUserId)
        } else {
            blockedUsers[blockingUserId] = [blockedUserId]
        }

        // 被ブロックユーザーのTrustScoreを減少
        if var blockedUser = users[blockedUserId] {
            blockedUser.trustScore = max(0.0, blockedUser.trustScore - 0.05)
            users[blockedUserId] = blockedUser
        }
    }

    func reportUser(
        reportingUserId: UUID,
        reportedUserId: UUID,
        reason: ReportReason,
        details: String?
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 450_000_000) // 0.45秒

        // 通報対象が存在するか確認
        guard users[reportedUserId] != nil else {
            throw RepositoryError.notFound
        }

        // 通報履歴に追加
        if reports[reportingUserId] != nil {
            reports[reportingUserId]?.append((reportedUserId, reason, details))
        } else {
            reports[reportingUserId] = [(reportedUserId, reason, details)]
        }

        // 被通報ユーザーのTrustScoreを減少
        if var reportedUser = users[reportedUserId] {
            reportedUser.trustScore = max(0.0, reportedUser.trustScore - 0.1)

            // 未成年通報の場合は即座にアカウント停止
            if reason == .minor {
                reportedUser.status = .suspended
            }

            users[reportedUserId] = reportedUser
        }

        // 通報後、自動的にブロック
        try await blockUser(blockingUserId: reportingUserId, blockedUserId: reportedUserId)
    }

    func fetchBlockedUsers(userId: UUID) async throws -> [UUID] {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        return Array(blockedUsers[userId] ?? [])
    }

    func unblockUser(
        unblockingUserId: UUID,
        unblockedUserId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        blockedUsers[unblockingUserId]?.remove(unblockedUserId)
    }

    func deleteAccount(userId: UUID) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        guard var user = users[userId] else {
            throw RepositoryError.notFound
        }

        // 論理削除
        user.status = .deleted
        users[userId] = user
    }

    func updateLastActive(userId: UUID) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒

        guard var user = users[userId] else {
            throw RepositoryError.notFound
        }

        user.lastActiveAt = Date()
        users[userId] = user
    }
}
