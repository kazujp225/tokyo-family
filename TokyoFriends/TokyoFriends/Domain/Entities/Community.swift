import Foundation

/// 区×興味のコミュニティ情報を管理
/// E-04: Community（コミュニティ）- 0.6_情報設計_データモデル.md
struct Community: Identifiable, Codable, Equatable, Hashable {
    /// コミュニティ一意識別子
    let id: UUID

    /// 名称（例: 新宿×カフェ）
    let name: String

    /// 区（例: 新宿区）
    let district: String

    /// 興味タグ（例: カフェ）
    let interestTag: String

    /// 参加者数
    var participantCount: Int

    /// サムネイル画像URL（任意）
    var thumbnailURL: String?

    /// 説明文（任意）
    var description: String?

    /// 作成日時
    let createdAt: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case district
        case interestTag = "interest_tag"
        case participantCount = "participant_count"
        case thumbnailURL = "thumbnail_url"
        case description
        case createdAt = "created_at"
    }

    // MARK: - Computed Properties

    /// コミュニティ名の自動生成（district × interest_tag）
    var generatedName: String {
        "\(district)×\(interestTag)"
    }

    /// 参加者数の表示用文字列
    var participantCountDisplayText: String {
        if participantCount >= 1000 {
            return "\(participantCount / 1000)K人"
        } else {
            return "\(participantCount)人"
        }
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String? = nil,
        district: String,
        interestTag: String,
        participantCount: Int = 0,
        thumbnailURL: String? = nil,
        description: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name ?? "\(district)×\(interestTag)" // 自動生成
        self.district = district
        self.interestTag = interestTag
        self.participantCount = max(0, participantCount)
        self.thumbnailURL = thumbnailURL
        self.description = description
        self.createdAt = createdAt
    }
}

// MARK: - Sample Data Extension

#if DEBUG
extension Community {
    /// テスト用サンプルコミュニティ
    static let samples: [Community] = [
        Community(
            district: "新宿区",
            interestTag: "カフェ",
            participantCount: 120,
            description: "新宿でカフェ巡りが好きな仲間が集まるコミュニティです。"
        ),
        Community(
            district: "新宿区",
            interestTag: "サウナ",
            participantCount: 50,
            description: "新宿周辺のサウナ好きが集まるコミュニティです。"
        ),
        Community(
            district: "渋谷区",
            interestTag: "音楽",
            participantCount: 80,
            description: "音楽好きが集まるコミュニティです。"
        ),
        Community(
            district: "渋谷区",
            interestTag: "アウトドア",
            participantCount: 65,
            description: "週末にアウトドア活動を楽しむコミュニティです。"
        )
    ]

    static let sample = samples[0]
}
#endif
