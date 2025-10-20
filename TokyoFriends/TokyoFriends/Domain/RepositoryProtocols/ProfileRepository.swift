import Foundation

/// プロフィールリポジトリプロトコル
/// 機能ID: F-01 (プロフィール登録), F-02 (プロフィール編集) - 0.3_機能定義.md
protocol ProfileRepository {

    /// プロフィールを作成
    /// - Parameter profile: プロフィールデータ
    /// - Returns: 作成されたプロフィール
    /// - Throws: バリデーションエラー、重複エラー
    func createProfile(_ profile: Profile) async throws -> Profile

    /// プロフィールを更新
    /// - Parameter profile: 更新するプロフィールデータ
    /// - Returns: 更新されたプロフィール
    /// - Throws: バリデーションエラー、存在しない場合
    func updateProfile(_ profile: Profile) async throws -> Profile

    /// プロフィールを取得
    /// - Parameter userId: ユーザーID
    /// - Returns: プロフィール（存在しない場合はnil）
    func fetchProfile(userId: UUID) async throws -> Profile?

    /// IGハンドルを更新
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - instagramHandle: Instagramハンドル（@なし）
    /// - Throws: バリデーションエラー
    func updateInstagramHandle(
        userId: UUID,
        instagramHandle: String
    ) async throws

    /// 写真を追加
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoURL: 写真URL（アップロード済み）
    /// - Throws: 最大枚数超過エラー（5枚まで）
    func addPhoto(
        userId: UUID,
        photoURL: String
    ) async throws

    /// 写真を削除
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoURL: 削除する写真URL
    /// - Throws: 最小枚数エラー（1枚は必須）
    func removePhoto(
        userId: UUID,
        photoURL: String
    ) async throws

    /// 写真の順序を変更
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoOrder: 新しい写真URLの順序
    func reorderPhotos(
        userId: UUID,
        photoOrder: [String]
    ) async throws
}

// MARK: - Validation

extension ProfileRepository {
    /// プロフィールのバリデーション
    /// - Parameter profile: 検証するプロフィール
    /// - Throws: バリデーションエラー
    func validateProfile(_ profile: Profile) throws {
        // 興味タグ: 3〜10個
        guard profile.interests.count >= 3 && profile.interests.count <= 10 else {
            throw ValidationError.interestCount
        }

        // Bio: 最大300文字
        if let bio = profile.bio, bio.count > 300 {
            throw ValidationError.bioTooLong
        }

        // 写真: 1〜5枚
        guard profile.photos.count >= 1 && profile.photos.count <= 5 else {
            throw ValidationError.photoCount
        }

        // 学校/職場: 必須
        guard !profile.schoolOrWork.isEmpty else {
            throw ValidationError.schoolOrWorkRequired
        }
    }
}

// MARK: - Validation Errors

enum ValidationError: Error, LocalizedError {
    case interestCount
    case bioTooLong
    case photoCount
    case schoolOrWorkRequired
    case invalidInstagramHandle

    var errorDescription: String? {
        switch self {
        case .interestCount:
            return "興味タグは3〜10個選択してください"
        case .bioTooLong:
            return "自己紹介は300文字以内で入力してください"
        case .photoCount:
            return "写真は1〜5枚登録してください"
        case .schoolOrWorkRequired:
            return "学校/職場を入力してください"
        case .invalidInstagramHandle:
            return "Instagramハンドルの形式が不正です"
        }
    }
}
