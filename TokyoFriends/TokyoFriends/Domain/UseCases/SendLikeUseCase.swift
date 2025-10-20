import Foundation

/// Like送信ユースケース
/// 機能ID: F-06 - Like送信、F-07 - マッチ成立（0.3_機能定義.md）
/// ビジネスロジック: Like送信、相互Like検知、マッチング成立処理
final class SendLikeUseCase {

    // MARK: - Dependencies

    private let matchRepository: MatchRepository
    private let userRepository: UserRepository

    // MARK: - Initializer

    init(
        matchRepository: MatchRepository,
        userRepository: UserRepository
    ) {
        self.matchRepository = matchRepository
        self.userRepository = userRepository
    }

    // MARK: - Execute

    /// Likeを送信し、マッチング判定
    /// - Parameters:
    ///   - fromUserId: 送信元ユーザーID
    ///   - toUserId: 送信先ユーザーID
    /// - Returns: マッチング成立の場合はMatch、未成立の場合はnil
    /// - Throws: ブロック済みユーザーの場合はエラー
    func execute(
        from fromUserId: UUID,
        to toUserId: UUID
    ) async throws -> Match? {
        // 1. ブロックリストをチェック
        let blockedUserIds = try await userRepository.fetchBlockedUsers(userId: fromUserId)

        if blockedUserIds.contains(toUserId) {
            throw UseCaseError.blockedUser
        }

        // 2. Likeを送信（相互Likeの場合はマッチング成立）
        let match = try await matchRepository.sendLike(
            from: fromUserId,
            to: toUserId
        )

        // 3. 最終アクティブ時刻を更新
        try? await userRepository.updateLastActive(userId: fromUserId)

        return match
    }
}

// MARK: - UseCase Errors

enum UseCaseError: Error, LocalizedError {
    case blockedUser
    case invalidInput
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .blockedUser:
            return "ブロックしたユーザーにはLikeを送信できません"
        case .invalidInput:
            return "入力内容が不正です"
        case .permissionDenied:
            return "この操作を実行する権限がありません"
        }
    }
}
