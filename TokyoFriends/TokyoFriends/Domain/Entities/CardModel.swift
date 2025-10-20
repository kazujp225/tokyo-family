import Foundation

/// 探索画面で表示する友達候補カード
/// 4.4. カード探索 - 0.3_機能定義.md
struct CardModel: Identifiable, Equatable {
    /// カードID（= ユーザーID）
    var id: UUID { userId }

    /// ユーザーID
    let userId: UUID

    /// プロフィール情報
    let profile: Profile

    /// 興味タグ一致度（0.0〜1.0）
    let interestMatchScore: Double

    /// 生活圏近接度（0.0〜1.0）
    let proximityScore: Double

    /// コミュニティ重複数
    let commonCommunitiesCount: Int

    /// 総合スコア（表示順序に使用）
    var totalScore: Double {
        // 興味タグ一致度（重み高: 0.5）
        // 生活圏近接（重み中: 0.3）
        // コミュニティ重複（重み低: 0.2）
        interestMatchScore * 0.5 +
        proximityScore * 0.3 +
        Double(commonCommunitiesCount) * 0.05 // 最大4コミュニティで0.2
    }

    // MARK: - Computed Properties

    /// 一致率の表示テキスト（例: "92%マッチ"）
    var matchPercentageText: String {
        let percentage = Int(interestMatchScore * 100)
        return "\(percentage)%マッチ"
    }

    /// 距離の表示テキスト（例: "同じ駅"）
    var proximityText: String {
        if proximityScore >= 0.9 {
            return "同じ駅"
        } else if proximityScore >= 0.6 {
            return "隣接駅"
        } else if proximityScore >= 0.3 {
            return "同じ区"
        } else {
            return "近隣"
        }
    }

    /// 共通コミュニティの表示テキスト
    var commonCommunitiesText: String? {
        guard commonCommunitiesCount > 0 else { return nil }
        return "\(commonCommunitiesCount)個の共通コミュニティ"
    }

    /// カードに表示する興味タグ（最大3つ）
    var displayInterests: [String] {
        Array(profile.interests.prefix(3))
    }

    /// カードに表示する写真（最初の写真）
    var primaryPhoto: String? {
        profile.photos.first
    }

    /// 自己紹介の短縮版（最大2行、約80文字）
    var shortBio: String {
        guard let bio = profile.bio else { return "" }
        let maxLength = 80
        if bio.count > maxLength {
            let index = bio.index(bio.startIndex, offsetBy: maxLength)
            return String(bio[..<index]) + "…"
        }
        return bio
    }
}

// MARK: - Sample Data Extension

#if DEBUG
extension CardModel {
    /// テスト用サンプルカード
    static let samples: [CardModel] = [
        CardModel(
            userId: UUID(),
            profile: Profile.sample,
            interestMatchScore: 0.85,
            proximityScore: 0.95,
            commonCommunitiesCount: 2
        ),
        CardModel(
            userId: UUID(),
            profile: Profile.workerSample,
            interestMatchScore: 0.65,
            proximityScore: 0.75,
            commonCommunitiesCount: 1
        ),
        CardModel(
            userId: UUID(),
            profile: Profile(
                userId: UUID(),
                ageRange: .range23_25,
                attribute: .student,
                schoolOrWork: "早稲田大学",
                district: "新宿区",
                nearestStation: "高田馬場駅",
                interests: ["サウナ", "カフェ", "スポーツ"],
                bio: "サウナとカフェが好きです。スポーツも時々します。",
                photos: [],
                photoOrder: []
            ),
            interestMatchScore: 0.75,
            proximityScore: 0.85,
            commonCommunitiesCount: 3
        )
    ]

    static let sample = samples[0]
}
#endif
