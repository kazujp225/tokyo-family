import Foundation

/// マッチ一覧取得ユースケース
/// 機能ID: F-08 - マッチ一覧（0.3_機能定義.md）
/// ビジネスロジック: アクティブマッチのみ取得、ブロック除外
final class FetchMatchesUseCase {

    // MARK: - Dependencies

    private let matchRepository: MatchRepository

    // MARK: - Initializer

    init(matchRepository: MatchRepository) {
        self.matchRepository = matchRepository
    }

    // MARK: - Execute

    /// アクティブなマッチ一覧を取得
    /// - Parameter userId: ユーザーID
    /// - Returns: アクティブなマッチのリスト（最新順）
    func execute(userId: UUID) async throws -> [Match] {
        // 1. マッチ一覧を取得
        let matches = try await matchRepository.fetchMatches(userId: userId)

        // 2. アクティブなマッチのみフィルタ（ブロック状態を除外）
        let activeMatches = matches.filter { $0.status == .active }

        return activeMatches
    }

    /// マッチ詳細を取得（相手プロフィール含む）
    /// - Parameters:
    ///   - matchId: マッチID
    ///   - requestingUserId: リクエスト元ユーザーID
    /// - Returns: マッチ詳細
    func fetchDetail(
        matchId: UUID,
        requestingUserId: UUID
    ) async throws -> MatchDetail {
        let matchDetail = try await matchRepository.fetchMatchDetail(
            matchId: matchId,
            requestingUserId: requestingUserId
        )

        return matchDetail
    }
}
