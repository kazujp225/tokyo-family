import Foundation

/// マッチ成立情報とIGハンドル参照権限を管理
/// E-06: Match（マッチ）- 0.6_情報設計_データモデル.md
struct Match: Identifiable, Codable, Equatable {
    /// マッチ一意識別子
    let id: UUID

    /// ユーザーA ID
    let userAId: UUID

    /// ユーザーB ID
    let userBId: UUID

    /// 成立日時
    let matchedAt: Date

    /// 状態
    var status: MatchStatus

    /// 相手のプロフィール（表示用）
    var partnerProfile: Profile?

    /// 相手のIGハンドル（マッチ成立後のみ）
    var partnerInstagramHandle: String?

    // MARK: - Nested Types

    /// マッチ状態
    enum MatchStatus: String, Codable {
        case active
        case blockedByA = "blocked_by_a"
        case blockedByB = "blocked_by_b"

        var isBlocked: Bool {
            self == .blockedByA || self == .blockedByB
        }
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case userAId = "user_a_id"
        case userBId = "user_b_id"
        case matchedAt = "matched_at"
        case status
        case partnerProfile = "partner_profile"
        case partnerInstagramHandle = "partner_instagram_handle"
    }

    // MARK: - Computed Properties

    /// 相手のユーザーIDを取得（自分のIDを渡す）
    func getPartnerId(myUserId: UUID) -> UUID {
        myUserId == userAId ? userBId : userAId
    }

    /// IGハンドルが表示可能かチェック
    var isInstagramHandleVisible: Bool {
        status == .active && partnerInstagramHandle != nil
    }

    /// Instagram深いリンクURL
    var instagramDeepLink: URL? {
        guard let handle = partnerInstagramHandle, status == .active else {
            return nil
        }
        // instagram://user?username={handle}
        return URL(string: "instagram://user?username=\(handle)")
    }

    /// Instagramブラウザフォールバック URL
    var instagramWebURL: URL? {
        guard let handle = partnerInstagramHandle, status == .active else {
            return nil
        }
        return URL(string: "https://instagram.com/\(handle)")
    }
}

// MARK: - Sample Data Extension

#if DEBUG
extension Match {
    /// テスト用サンプルマッチ
    static let sample = Match(
        id: UUID(),
        userAId: UUID(),
        userBId: UUID(),
        matchedAt: Date(),
        status: .active,
        partnerProfile: Profile.sample,
        partnerInstagramHandle: "tokyo_friend_sample"
    )

    /// ブロック済みサンプルマッチ
    static let blockedSample = Match(
        id: UUID(),
        userAId: UUID(),
        userBId: UUID(),
        matchedAt: Date().addingTimeInterval(-86400), // 1日前
        status: .blockedByA,
        partnerProfile: Profile.sample,
        partnerInstagramHandle: nil
    )
}
#endif
