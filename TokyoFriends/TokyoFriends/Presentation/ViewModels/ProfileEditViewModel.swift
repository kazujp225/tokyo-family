import Foundation
import Observation

/// プロフィール編集ViewModel
/// 画面ID: PG-60, PG-61 - プロフィール編集（0.4_ページ定義.md）
/// MVVM + Observation pattern（iOS 17+）
@Observable
final class ProfileEditViewModel {

    // MARK: - Published State

    var profile: Profile?
    var isLoading: Bool = false
    var isSaving: Bool = false
    var errorMessage: String?
    var validationErrors: [String] = []
    var showSuccessMessage: Bool = false

    // MARK: - Dependencies

    private let profileRepository: ProfileRepository
    private let updateProfileUseCase: UpdateProfileUseCase
    let currentUserId: UUID

    // MARK: - Computed Properties

    var canSave: Bool {
        validationErrors.isEmpty && !isSaving
    }

    // MARK: - Initializer

    init(
        profileRepository: ProfileRepository,
        updateProfileUseCase: UpdateProfileUseCase,
        currentUserId: UUID
    ) {
        self.profileRepository = profileRepository
        self.updateProfileUseCase = updateProfileUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// プロフィールを読み込み
    @MainActor
    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileRepository.fetchProfile(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// プロフィールを保存
    @MainActor
    func saveProfile() async {
        guard let profile = profile else { return }

        isSaving = true
        errorMessage = nil
        validationErrors = []

        do {
            // バリデーション
            try validateProfile(profile)

            // 保存
            self.profile = try await updateProfileUseCase.execute(profile)

            showSuccessMessage = true

            // 成功メッセージを3秒後に消す
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    showSuccessMessage = false
                }
            }
        } catch let error as ValidationError {
            validationErrors = [error.localizedDescription]
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    /// 写真を追加
    @MainActor
    func addPhoto(_ photoURL: String) async {
        do {
            try await updateProfileUseCase.addPhoto(userId: currentUserId, photoURL: photoURL)
            await loadProfile() // 再読み込み
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 写真を削除
    @MainActor
    func removePhoto(_ photoURL: String) async {
        do {
            try await updateProfileUseCase.removePhoto(userId: currentUserId, photoURL: photoURL)
            await loadProfile() // 再読み込み
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 写真の順序を変更
    @MainActor
    func reorderPhotos(_ photoOrder: [String]) async {
        do {
            try await updateProfileUseCase.reorderPhotos(userId: currentUserId, photoOrder: photoOrder)
            profile?.photoOrder = photoOrder
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Instagramハンドルを更新
    @MainActor
    func updateInstagramHandle(_ handle: String) async {
        do {
            try await updateProfileUseCase.updateInstagramHandle(
                userId: currentUserId,
                instagramHandle: handle
            )
            showSuccessMessage = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Validation

    private func validateProfile(_ profile: Profile) throws {
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

// MARK: - Factory

extension ProfileEditViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> ProfileEditViewModel {
        let provider = RepositoryProvider.shared

        let updateProfileUseCase = UpdateProfileUseCase(
            profileRepository: provider.profileRepository
        )

        return ProfileEditViewModel(
            profileRepository: provider.profileRepository,
            updateProfileUseCase: updateProfileUseCase,
            currentUserId: currentUserId
        )
    }
}
