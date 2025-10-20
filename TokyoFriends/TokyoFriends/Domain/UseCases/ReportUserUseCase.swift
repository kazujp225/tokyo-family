import Foundation

/// ユーザー通報ユースケース
/// 機能ID: F-04 - 通報（0.3_機能定義.md）
/// ビジネスロジック: 通報処理、自動ブロック
final class ReportUserUseCase {

    // MARK: - Dependencies

    private let userRepository: UserRepository

    // MARK: - Initializer

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // MARK: - Execute

    /// ユーザーを通報
    /// - Parameters:
    ///   - reportingUserId: 通報するユーザーID
    ///   - reportedUserId: 通報されるユーザーID
    ///   - reason: 通報理由
    ///   - details: 詳細説明（任意）
    /// - Note: 通報後、自動的にブロックも実行
    func execute(
        reportingUserId: UUID,
        reportedUserId: UUID,
        reason: ReportReason,
        details: String?
    ) async throws {
        // バリデーション: 詳細が長すぎる場合はエラー
        if let details = details, details.count > 500 {
            throw UseCaseError.invalidInput
        }

        // ユーザーを通報（自動的にブロックも実行）
        try await userRepository.reportUser(
            reportingUserId: reportingUserId,
            reportedUserId: reportedUserId,
            reason: reason,
            details: details
        )
    }
}
