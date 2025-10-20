import Foundation

/// マッチングリポジトリのモック実装
/// テスト・開発用（MockDataを使用）
final class MockMatchRepository: MatchRepository {

    // MARK: - Private Properties

    /// Likeを送った記録（from -> [to]）
    private var sentLikes: [UUID: Set<UUID>] = [:]

    /// Skipした記録（userId -> [skippedUserId]）
    private var skippedUsers: [UUID: Set<UUID>] = [:]

    /// マッチ一覧（userId -> [Match]）
    private var matches: [UUID: [Match]] = [:]

    // MARK: - MatchRepository

    func sendLike(
        from fromUserId: UUID,
        to toUserId: UUID
    ) async throws -> Match? {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4秒

        // Likeを記録
        if sentLikes[fromUserId] != nil {
            sentLikes[fromUserId]?.insert(toUserId)
        } else {
            sentLikes[fromUserId] = [toUserId]
        }

        // 相互Likeかチェック
        let isMatchReciprocated = sentLikes[toUserId]?.contains(fromUserId) ?? false

        if isMatchReciprocated {
            // マッチング成立
            let match = createMatch(userAId: fromUserId, userBId: toUserId)

            // 双方のマッチリストに追加
            addMatchToUser(match, userId: fromUserId)
            addMatchToUser(match, userId: toUserId)

            return match
        }

        return nil
    }

    func recordSkip(
        userId: UUID,
        skippedUserId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒

        if skippedUsers[userId] != nil {
            skippedUsers[userId]?.insert(skippedUserId)
        } else {
            skippedUsers[userId] = [skippedUserId]
        }
    }

    func fetchMatches(userId: UUID) async throws -> [Match] {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        // マッチが存在しない場合はモックデータから生成
        if matches[userId] == nil {
            matches[userId] = MockData.generateMatches(userId: userId)
        }

        // 最新順でソート
        let userMatches = matches[userId] ?? []
        return userMatches.sorted { $0.matchedAt > $1.matchedAt }
    }

    func blockMatch(
        matchId: UUID,
        blockingUserId: UUID
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        // マッチを検索して状態を更新
        guard var userMatches = matches[blockingUserId],
              let matchIndex = userMatches.firstIndex(where: { $0.id == matchId })
        else {
            throw RepositoryError.notFound
        }

        var match = userMatches[matchIndex]

        // ブロック状態を更新
        if match.userAId == blockingUserId {
            match.status = .blockedByA
        } else if match.userBId == blockingUserId {
            match.status = .blockedByB
        }

        userMatches[matchIndex] = match
        matches[blockingUserId] = userMatches
    }

    func fetchMatchDetail(
        matchId: UUID,
        requestingUserId: UUID
    ) async throws -> MatchDetail {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        // マッチを検索
        guard let userMatches = matches[requestingUserId],
              let match = userMatches.first(where: { $0.id == matchId })
        else {
            throw RepositoryError.notFound
        }

        // 相手のユーザーIDを特定
        let partnerId = match.userAId == requestingUserId ? match.userBId : match.userAId

        // 相手のプロフィールとユーザー情報を取得
        guard let partnerProfile = MockData.profiles.first(where: { $0.userId == partnerId }),
              let partnerUser = MockData.users.first(where: { $0.id == partnerId })
        else {
            throw RepositoryError.notFound
        }

        return MatchDetail(
            match: match,
            partnerProfile: partnerProfile,
            partnerUser: partnerUser
        )
    }

    // MARK: - Private Helpers

    /// マッチを作成
    private func createMatch(userAId: UUID, userBId: UUID) -> Match {
        // 相手のプロフィールを取得
        let partnerProfile = MockData.profiles.first { $0.userId == userBId }
        let partnerInstagramHandle = "ig_\(userBId.uuidString.prefix(8))"

        return Match(
            id: UUID(),
            userAId: userAId,
            userBId: userBId,
            matchedAt: Date(),
            status: .active,
            partnerProfile: partnerProfile,
            partnerInstagramHandle: partnerInstagramHandle
        )
    }

    /// ユーザーのマッチリストにマッチを追加
    private func addMatchToUser(_ match: Match, userId: UUID) {
        if matches[userId] != nil {
            matches[userId]?.append(match)
        } else {
            matches[userId] = [match]
        }
    }
}
