import Foundation

/// ユーザーブロックユースケース
/// 機能ID: F-04 - ブロック（0.3_機能定義.md）
/// ビジネスロジック: ブロック処理、マッチ解除
final class BlockUserUseCase {

    // MARK: - Dependencies

    private let userRepository: UserRepository
    private let matchRepository: MatchRepository

    // MARK: - Initializer

    init(
        userRepository: UserRepository,
        matchRepository: MatchRepository
    ) {
        self.userRepository = userRepository
        self.matchRepository = matchRepository
    }

    // MARK: - Execute

    /// ユーザーをブロック
    /// - Parameters:
    ///   - blockingUserId: ブロックするユーザーID
    ///   - blockedUserId: ブロックされるユーザーID
    /// - Note: ブロック後、該当するマッチも自動的にブロック状態に変更
    func execute(
        blockingUserId: UUID,
        blockedUserId: UUID
    ) async throws {
        // 1. ユーザーをブロック
        try await userRepository.blockUser(
            blockingUserId: blockingUserId,
            blockedUserId: blockedUserId
        )

        // 2. マッチが存在する場合はブロック状態に変更
        let matches = try? await matchRepository.fetchMatches(userId: blockingUserId)
        if let matches = matches {
            for match in matches {
                // ブロック対象ユーザーとのマッチを検索
                if match.userAId == blockedUserId || match.userBId == blockedUserId {
                    try? await matchRepository.blockMatch(
                        matchId: match.id,
                        blockingUserId: blockingUserId
                    )
                }
            }
        }
    }
}
