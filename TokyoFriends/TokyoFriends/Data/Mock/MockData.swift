import Foundation

/// モックデータ生成
/// テスト用のユーザー・コミュニティ・プロフィールデータ
/// 5.2 テストデータ - 0.9_テスト_受け入れ基準.md
enum MockData {

    // MARK: - Users

    /// テスト用ユーザーリスト（18歳以上）
    static let users: [User] = [
        User(id: UUID(), authMethod: .phone, status: .active),
        User(id: UUID(), trustScore: 0.9, authMethod: .apple, status: .active),
        User(id: UUID(), trustScore: 0.8, authMethod: .phone, status: .active),
        User(id: UUID(), trustScore: 0.95, authMethod: .apple, status: .active),
        User(id: UUID(), trustScore: 0.75, authMethod: .phone, status: .active),
        User(id: UUID(), trustScore: 0.85, authMethod: .phone, status: .active),
        User(id: UUID(), trustScore: 0.9, authMethod: .apple, status: .active),
        User(id: UUID(), trustScore: 0.88, authMethod: .phone, status: .active),
        User(id: UUID(), trustScore: 0.92, authMethod: .apple, status: .active),
        User(id: UUID(), trustScore: 0.78, authMethod: .phone, status: .active)
    ]

    // MARK: - Profiles

    /// テスト用プロフィールリスト
    static let profiles: [Profile] = [
        Profile(
            userId: users[0].id,
            ageRange: .range20_22,
            attribute: .student,
            schoolOrWork: "東京大学",
            district: "新宿区",
            nearestStation: "新宿駅",
            interests: ["カフェ", "サウナ", "写真", "音楽"],
            bio: "週末カフェ巡りが好きです。サウナと写真も趣味です。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[1].id,
            ageRange: .range23_25,
            attribute: .worker,
            schoolOrWork: "IT企業勤務",
            district: "渋谷区",
            nearestStation: "渋谷駅",
            interests: ["アウトドア", "映画", "カフェ"],
            bio: "アウトドアが好きで、週末はよく登山に行きます。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[2].id,
            ageRange: .range20_22,
            attribute: .student,
            schoolOrWork: "早稲田大学",
            district: "新宿区",
            nearestStation: "高田馬場駅",
            interests: ["サウナ", "カフェ", "スポーツ", "読書"],
            bio: "サウナとカフェが好きです。スポーツも時々します。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[3].id,
            ageRange: .range18_19,
            attribute: .student,
            schoolOrWork: "慶應義塾大学",
            district: "港区",
            nearestStation: "三田駅",
            interests: ["音楽", "アート", "カフェ"],
            bio: "音楽とアートが好きで、よくギャラリーに行きます。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[4].id,
            ageRange: .range26Plus,
            attribute: .worker,
            schoolOrWork: "コンサルティング会社",
            district: "千代田区",
            nearestStation: "東京駅",
            interests: ["グルメ", "ワイン", "旅行"],
            bio: "グルメとワインが好きです。国内外の旅行によく行きます。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[5].id,
            ageRange: .range23_25,
            attribute: .worker,
            schoolOrWork: "広告代理店",
            district: "渋谷区",
            nearestStation: "表参道駅",
            interests: ["ファッション", "カフェ", "写真"],
            bio: "ファッションと写真が趣味です。表参道のカフェ巡りをよくします。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[6].id,
            ageRange: .range20_22,
            attribute: .student,
            schoolOrWork: "上智大学",
            district: "千代田区",
            nearestStation: "四ツ谷駅",
            interests: ["語学", "映画", "読書"],
            bio: "英語と中国語を勉強中です。映画と読書も好きです。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[7].id,
            ageRange: .range23_25,
            attribute: .student,
            schoolOrWork: "東京藝術大学",
            district: "台東区",
            nearestStation: "上野駅",
            interests: ["アート", "音楽", "写真", "カフェ"],
            bio: "美術を勉強しています。音楽と写真も好きです。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[8].id,
            ageRange: .range26Plus,
            attribute: .worker,
            schoolOrWork: "スタートアップ企業",
            district: "渋谷区",
            nearestStation: "渋谷駅",
            interests: ["テック", "スタートアップ", "読書"],
            bio: "スタートアップで働いています。テックとビジネス書が好きです。",
            photos: [],
            photoOrder: []
        ),
        Profile(
            userId: users[9].id,
            ageRange: .range20_22,
            attribute: .student,
            schoolOrWork: "明治大学",
            district: "新宿区",
            nearestStation: "新宿駅",
            interests: ["スポーツ", "サウナ", "カフェ"],
            bio: "スポーツとサウナが好きです。新宿のカフェによく行きます。",
            photos: [],
            photoOrder: []
        )
    ]

    // MARK: - Communities

    /// テスト用コミュニティリスト
    static let communities: [Community] = [
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
            description: "音楽好きが集まるコミュニティです。ライブやフェス情報を共有しています。"
        ),
        Community(
            district: "渋谷区",
            interestTag: "アウトドア",
            participantCount: 65,
            description: "週末にアウトドア活動を楽しむコミュニティです。"
        ),
        Community(
            district: "新宿区",
            interestTag: "写真",
            participantCount: 45,
            description: "写真好きが集まるコミュニティです。撮影会も開催しています。"
        ),
        Community(
            district: "渋谷区",
            interestTag: "カフェ",
            participantCount: 90,
            description: "渋谷のカフェ巡りが好きな方々のコミュニティです。"
        ),
        Community(
            district: "港区",
            interestTag: "アート",
            participantCount: 55,
            description: "アート好きが集まるコミュニティです。展示会情報を共有しています。"
        ),
        Community(
            district: "千代田区",
            interestTag: "読書",
            participantCount: 40,
            description: "読書好きが集まるコミュニティです。読書会も開催しています。"
        )
    ]

    // MARK: - Cards

    /// テスト用カードリスト
    static func generateCards(excludeUserId: UUID? = nil) -> [CardModel] {
        profiles.enumerated().compactMap { index, profile in
            if let excludeId = excludeUserId, profile.userId == excludeId {
                return nil
            }

            // 興味タグ一致度（ランダム: 0.6〜0.95）
            let interestMatch = Double.random(in: 0.6...0.95)

            // 生活圏近接度（ランダム: 0.5〜1.0）
            let proximity = Double.random(in: 0.5...1.0)

            // 共通コミュニティ数（ランダム: 0〜3）
            let commonCommunities = Int.random(in: 0...3)

            return CardModel(
                userId: profile.userId,
                profile: profile,
                interestMatchScore: interestMatch,
                proximityScore: proximity,
                commonCommunitiesCount: commonCommunities
            )
        }
    }

    // MARK: - Matches

    /// テスト用マッチリスト
    static func generateMatches(userId: UUID) -> [Match] {
        let partnerProfiles = profiles.prefix(3)

        return partnerProfiles.map { profile in
            Match(
                id: UUID(),
                userAId: userId,
                userBId: profile.userId,
                matchedAt: Date().addingTimeInterval(-Double.random(in: 3600...86400)), // 1時間〜1日前
                status: .active,
                partnerProfile: profile,
                partnerInstagramHandle: "ig_\(profile.userId.uuidString.prefix(8))"
            )
        }
    }

    // MARK: - Current User

    /// 現在のユーザー（テスト用）
    static let currentUser = users[0]

    /// 現在のユーザーのプロフィール
    static let currentUserProfile = profiles[0]
}
