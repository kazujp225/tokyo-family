import Foundation

/// マッチングリポジトリプロトコル
/// 機能ID: F-06 (Like送信), F-07 (マッチ成立), F-08 (マッチ一覧) - 0.3_機能定義.md
protocol MatchRepository {

    /// Likeを送信
    /// - Parameters:
    ///   - fromUserId: 送信元ユーザーID
    ///   - toUserId: 送信先ユーザーID
    /// - Returns: マッチング成立の場合はMatch、未成立の場合はnil
    /// - Note: 相互Likeの場合、自動的にマッチング成立
    func sendLike(
        from fromUserId: UUID,
        to toUserId: UUID
    ) async throws -> Match?

    /// Skipを記録
    /// - Parameters:
    ///   - userId: スキップしたユーザーID
    ///   - skippedUserId: スキップされたユーザーID
    /// - Note: 一定期間は同じカードを表示しない
    func recordSkip(
        userId: UUID,
        skippedUserId: UUID
    ) async throws

    /// マッチ一覧を取得
    /// - Parameter userId: ユーザーID
    /// - Returns: アクティブなマッチのリスト（最新順）
    func fetchMatches(userId: UUID) async throws -> [Match]

    /// マッチをブロック
    /// - Parameters:
    ///   - matchId: マッチID
    ///   - blockingUserId: ブロックするユーザーID
    /// - Note: ブロック後はIGハンドルが非表示になる
    func blockMatch(
        matchId: UUID,
        blockingUserId: UUID
    ) async throws

    /// マッチの詳細を取得
    /// - Parameters:
    ///   - matchId: マッチID
    ///   - requestingUserId: リクエスト元ユーザーID
    /// - Returns: マッチ詳細（相手プロフィール・IGハンドル含む）
    func fetchMatchDetail(
        matchId: UUID,
        requestingUserId: UUID
    ) async throws -> MatchDetail
}

// MARK: - Match Detail Model

/// マッチ詳細（リポジトリ返却用）
struct MatchDetail: Equatable {
    let match: Match
    let partnerProfile: Profile
    let partnerUser: User

    /// IGハンドルが表示可能か（アクティブマッチの場合のみ）
    var canShowInstagramHandle: Bool {
        match.status == .active
    }
}
