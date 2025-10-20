import Foundation

/// ユーザーの基本情報と信頼性スコアを管理
/// E-01: User（ユーザー）- 0.6_情報設計_データモデル.md
struct User: Identifiable, Codable, Equatable {
    /// ユーザー一意識別子（UUIDv4）
    let id: UUID

    /// 作成日時（UTC）
    let createdAt: Date

    /// 最終活動日時
    var lastActiveAt: Date

    /// 信頼スコア（0.0〜1.0）
    /// - Note: 通報・ブロック受信で減少、正常利用で徐々に回復
    var trustScore: Double

    /// 認証方法
    let authMethod: AuthMethod

    /// アカウント状態
    var status: AccountStatus

    /// 認証方法の種別
    enum AuthMethod: String, Codable {
        case phone
        case apple
    }

    /// アカウント状態
    enum AccountStatus: String, Codable {
        case active
        case suspended
        case deleted
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case lastActiveAt = "last_active_at"
        case trustScore = "trust_score"
        case authMethod = "auth_method"
        case status
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        lastActiveAt: Date = Date(),
        trustScore: Double = 1.0,
        authMethod: AuthMethod,
        status: AccountStatus = .active
    ) {
        self.id = id
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.trustScore = max(0.0, min(1.0, trustScore)) // 0.0〜1.0に制約
        self.authMethod = authMethod
        self.status = status
    }
}

// MARK: - Sample Data Extension

#if DEBUG
extension User {
    /// テスト用サンプルユーザー
    static let sample = User(
        id: UUID(),
        authMethod: .phone,
        status: .active
    )

    /// 低信頼スコアのサンプルユーザー
    static let lowTrustSample = User(
        id: UUID(),
        trustScore: 0.3,
        authMethod: .phone,
        status: .active
    )
}
#endif
