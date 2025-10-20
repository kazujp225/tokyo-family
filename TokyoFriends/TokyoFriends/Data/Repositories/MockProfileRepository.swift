import Foundation

/// プロフィールリポジトリのモック実装
/// テスト・開発用（MockDataを使用）
final class MockProfileRepository: ProfileRepository {

    // MARK: - Private Properties

    /// プロフィールストレージ（userId -> Profile）
    private var profiles: [UUID: Profile] = [:]

    /// Instagramハンドルストレージ（userId -> handle）
    private var instagramHandles: [UUID: String] = [:]

    // MARK: - Initializer

    init() {
        // モックデータを初期ロード
        for profile in MockData.profiles {
            profiles[profile.userId] = profile
        }

        // モックのIGハンドルを生成
        for user in MockData.users {
            instagramHandles[user.id] = "ig_\(user.id.uuidString.prefix(8))"
        }
    }

    // MARK: - ProfileRepository

    func createProfile(_ profile: Profile) async throws -> Profile {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        // バリデーション
        try validateProfile(profile)

        // 重複チェック
        if profiles[profile.userId] != nil {
            throw RepositoryError.invalidData
        }

        // プロフィールを保存
        profiles[profile.userId] = profile

        return profile
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 450_000_000) // 0.45秒

        // バリデーション
        try validateProfile(profile)

        // 存在チェック
        guard profiles[profile.userId] != nil else {
            throw RepositoryError.notFound
        }

        // プロフィールを更新
        profiles[profile.userId] = profile

        return profile
    }

    func fetchProfile(userId: UUID) async throws -> Profile? {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        return profiles[userId]
    }

    func updateInstagramHandle(
        userId: UUID,
        instagramHandle: String
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        // バリデーション: @なし、3〜30文字、英数字とアンダースコアのみ
        let trimmedHandle = instagramHandle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedHandle.count >= 3,
              trimmedHandle.count <= 30,
              trimmedHandle.range(of: "^[a-zA-Z0-9_]+$", options: .regularExpression) != nil
        else {
            throw ValidationError.invalidInstagramHandle
        }

        instagramHandles[userId] = trimmedHandle
    }

    func addPhoto(
        userId: UUID,
        photoURL: String
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4秒

        guard var profile = profiles[userId] else {
            throw RepositoryError.notFound
        }

        // 最大枚数チェック
        guard profile.photos.count < 5 else {
            throw ValidationError.photoCount
        }

        profile.photos.append(photoURL)
        profile.photoOrder.append(photoURL)
        profiles[userId] = profile
    }

    func removePhoto(
        userId: UUID,
        photoURL: String
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 350_000_000) // 0.35秒

        guard var profile = profiles[userId] else {
            throw RepositoryError.notFound
        }

        // 最小枚数チェック（1枚は必須）
        guard profile.photos.count > 1 else {
            throw ValidationError.photoCount
        }

        profile.photos.removeAll { $0 == photoURL }
        profile.photoOrder.removeAll { $0 == photoURL }
        profiles[userId] = profile
    }

    func reorderPhotos(
        userId: UUID,
        photoOrder: [String]
    ) async throws {
        // シミュレート: ネットワーク遅延
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒

        guard var profile = profiles[userId] else {
            throw RepositoryError.notFound
        }

        // 写真URLが一致するか確認
        let photosSet = Set(profile.photos)
        let orderSet = Set(photoOrder)

        guard photosSet == orderSet else {
            throw RepositoryError.invalidData
        }

        profile.photoOrder = photoOrder
        profiles[userId] = profile
    }
}
