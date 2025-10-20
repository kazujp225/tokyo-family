import Foundation

/// プロフィール更新ユースケース
/// 機能ID: F-02 - プロフィール編集（0.3_機能定義.md）
/// ビジネスロジック: バリデーション、プロフィール更新
final class UpdateProfileUseCase {

    // MARK: - Dependencies

    private let profileRepository: ProfileRepository

    // MARK: - Initializer

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    // MARK: - Execute

    /// プロフィールを更新
    /// - Parameter profile: 更新するプロフィールデータ
    /// - Returns: 更新されたプロフィール
    /// - Throws: バリデーションエラー、存在しない場合
    func execute(_ profile: Profile) async throws -> Profile {
        // 1. バリデーション
        try profileRepository.validateProfile(profile)

        // 2. プロフィールを更新
        let updatedProfile = try await profileRepository.updateProfile(profile)

        return updatedProfile
    }

    /// 写真を追加
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoURL: 写真URL
    func addPhoto(userId: UUID, photoURL: String) async throws {
        try await profileRepository.addPhoto(userId: userId, photoURL: photoURL)
    }

    /// 写真を削除
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoURL: 削除する写真URL
    func removePhoto(userId: UUID, photoURL: String) async throws {
        try await profileRepository.removePhoto(userId: userId, photoURL: photoURL)
    }

    /// 写真の順序を変更
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - photoOrder: 新しい写真URLの順序
    func reorderPhotos(userId: UUID, photoOrder: [String]) async throws {
        try await profileRepository.reorderPhotos(userId: userId, photoOrder: photoOrder)
    }

    /// Instagramハンドルを更新
    /// - Parameters:
    ///   - userId: ユーザーID
    ///   - instagramHandle: Instagramハンドル（@なし）
    func updateInstagramHandle(userId: UUID, instagramHandle: String) async throws {
        try await profileRepository.updateInstagramHandle(
            userId: userId,
            instagramHandle: instagramHandle
        )
    }
}
