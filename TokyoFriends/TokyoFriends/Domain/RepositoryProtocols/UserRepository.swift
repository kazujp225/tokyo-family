import Foundation

/// ユーザーリポジトリプロトコル
/// 機能ID: F-04 (ブロック/通報), F-09 (年齢認証) - 0.3_機能定義.md
protocol UserRepository {

    /// ユーザーを取得
    /// - Parameter userId: ユーザーID
    /// - Returns: ユーザー情報
    func fetchUser(userId: UUID) async throws -> User

    /// ユーザーを作成（初回登録時）
    /// - Parameters:
    ///   - authMethod: 認証方法（電話 or Apple）
    ///   - isOver18: 18歳以上かどうか
    /// - Returns: 作成されたユーザー
    /// - Throws: 18歳未満の場合は拒否
    func createUser(
        authMethod: AuthMethod,
        isOver18: Bool
    ) async throws -> User

    /// ユーザーをブロック
    /// - Parameters:
    ///   - blockingUserId: ブロックするユーザーID
    ///   - blockedUserId: ブロックされるユーザーID
    /// - Note: ブロック後はカード表示されず、マッチも解除
    func blockUser(
        blockingUserId: UUID,
        blockedUserId: UUID
    ) async throws

    /// ユーザーを通報
    /// - Parameters:
    ///   - reportingUserId: 通報するユーザーID
    ///   - reportedUserId: 通報されるユーザーID
    ///   - reason: 通報理由
    ///   - details: 詳細説明（任意）
    /// - Note: 通報後、自動的にブロックも実行
    func reportUser(
        reportingUserId: UUID,
        reportedUserId: UUID,
        reason: ReportReason,
        details: String?
    ) async throws

    /// ブロックリストを取得
    /// - Parameter userId: ユーザーID
    /// - Returns: ブロックしたユーザーIDのリスト
    func fetchBlockedUsers(userId: UUID) async throws -> [UUID]

    /// ユーザーをアンブロック
    /// - Parameters:
    ///   - unblockingUserId: ブロック解除するユーザーID
    ///   - unblockedUserId: ブロック解除されるユーザーID
    func unblockUser(
        unblockingUserId: UUID,
        unblockedUserId: UUID
    ) async throws

    /// アカウントを削除
    /// - Parameter userId: 削除するユーザーID
    /// - Note: 論理削除（status = .deleted）
    func deleteAccount(userId: UUID) async throws

    /// 最終アクティブ時刻を更新
    /// - Parameter userId: ユーザーID
    func updateLastActive(userId: UUID) async throws
}

// MARK: - Report Reason

/// 通報理由
enum ReportReason: String, Codable, CaseIterable {
    case spam = "スパム・営業行為"
    case harassment = "嫌がらせ・暴言"
    case inappropriate = "不適切なコンテンツ"
    case fake = "なりすまし・虚偽"
    case minor = "未成年と思われる"
    case other = "その他"

    var description: String {
        rawValue
    }
}
