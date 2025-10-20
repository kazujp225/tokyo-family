import Foundation

/// プロフィール作成ユースケース
/// 機能ID: F-01 - プロフィール登録（0.3_機能定義.md）
/// ビジネスロジック: バリデーション、プロフィール作成
final class CreateProfileUseCase {

    // MARK: - Dependencies

    private let profileRepository: ProfileRepository

    // MARK: - Initializer

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    // MARK: - Execute

    /// プロフィールを作成
    /// - Parameter profile: プロフィールデータ
    /// - Returns: 作成されたプロフィール
    /// - Throws: バリデーションエラー、重複エラー
    func execute(_ profile: Profile) async throws -> Profile {
        // 1. バリデーション（リポジトリ側でも実施）
        try profileRepository.validateProfile(profile)

        // 2. プロフィールを作成
        let createdProfile = try await profileRepository.createProfile(profile)

        return createdProfile
    }
}
