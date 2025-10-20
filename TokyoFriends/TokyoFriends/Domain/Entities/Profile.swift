import Foundation

/// ユーザーの自己情報・興味を管理
/// E-02: Profile（プロフィール）- 0.6_情報設計_データモデル.md
struct Profile: Identifiable, Codable, Equatable {
    /// プロフィールID（= ユーザーID）
    var id: UUID { userId }

    /// ユーザーID（外部キー）
    let userId: UUID

    /// 年齢帯
    let ageRange: AgeRange

    /// 属性（学生/社会人）
    let attribute: Attribute

    /// 学校名 or 勤務形態
    let schoolOrWork: String

    /// 居住区（例: 新宿区）
    let district: String

    /// 最寄駅（例: 新宿駅）
    let nearestStation: String

    /// 興味タグ（3〜10個）
    var interests: [String]

    /// 自己紹介（最大300文字、任意）
    var bio: String?

    /// 写真URL（最大5枚、任意）
    var photos: [String]

    /// 写真表示順序
    var photoOrder: [Int]

    // MARK: - Nested Types

    /// 年齢帯
    enum AgeRange: String, Codable, CaseIterable {
        case range18_19 = "18-19"
        case range20_22 = "20-22"
        case range23_25 = "23-25"
        case range26Plus = "26+"

        var displayName: String {
            switch self {
            case .range18_19: return "18–19歳"
            case .range20_22: return "20–22歳"
            case .range23_25: return "23–25歳"
            case .range26Plus: return "26歳以上"
            }
        }
    }

    /// 属性
    enum Attribute: String, Codable, CaseIterable {
        case student
        case worker

        var displayName: String {
            switch self {
            case .student: return "学生"
            case .worker: return "社会人"
            }
        }
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case ageRange = "age_range"
        case attribute
        case schoolOrWork = "school_or_work"
        case district
        case nearestStation = "nearest_station"
        case interests
        case bio
        case photos
        case photoOrder = "photo_order"
    }

    // MARK: - Validation

    /// 興味タグが有効範囲内（3〜10個）かチェック
    var isInterestsValid: Bool {
        interests.count >= 3 && interests.count <= 10
    }

    /// 自己紹介が有効範囲内（最大300文字）かチェック
    var isBioValid: Bool {
        guard let bio = bio else { return true }
        return bio.count <= 300
    }

    /// 写真が有効範囲内（最大5枚）かチェック
    var isPhotosValid: Bool {
        photos.count <= 5
    }
}

// MARK: - Sample Data Extension

#if DEBUG
extension Profile {
    /// テスト用サンプルプロフィール
    static let sample = Profile(
        userId: UUID(),
        ageRange: .range20_22,
        attribute: .student,
        schoolOrWork: "東京大学",
        district: "新宿区",
        nearestStation: "新宿駅",
        interests: ["カフェ", "サウナ", "写真", "音楽"],
        bio: "週末カフェ巡りが好きです。サウナと写真も趣味です。",
        photos: [],
        photoOrder: []
    )

    /// 社会人のサンプルプロフィール
    static let workerSample = Profile(
        userId: UUID(),
        ageRange: .range23_25,
        attribute: .worker,
        schoolOrWork: "IT企業勤務",
        district: "渋谷区",
        nearestStation: "渋谷駅",
        interests: ["アウトドア", "映画", "カフェ"],
        bio: "アウトドアが好きで、週末はよく登山に行きます。",
        photos: [],
        photoOrder: []
    )
}
#endif
