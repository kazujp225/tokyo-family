import Foundation
import Observation

/// オンボーディングViewModel
/// 画面ID: PG-05〜09 - オンボーディング（0.4_ページ定義.md）
/// 機能ID: F-01 - プロフィール登録（0.3_機能定義.md）
@Observable
final class OnboardingViewModel {

    // MARK: - Published State

    var currentStep: OnboardingStep = .basicInfo
    var profile: Profile
    var selectedInterests: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String?
    var validationErrors: [String] = []

    // MARK: - Onboarding Steps

    enum OnboardingStep: Int, CaseIterable {
        case basicInfo = 0      // 基本属性
        case interests = 1      // 興味タグ
        case photos = 2         // 写真
        case instagram = 3      // IGハンドル
        case complete = 4       // 完了

        var progress: Double {
            Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
        }

        var title: String {
            switch self {
            case .basicInfo: return "基本情報"
            case .interests: return "興味タグ"
            case .photos: return "写真"
            case .instagram: return "Instagram"
            case .complete: return "完了"
            }
        }
    }

    // MARK: - Dependencies

    private let createProfileUseCase: CreateProfileUseCase
    private let updateProfileUseCase: UpdateProfileUseCase
    private let currentUserId: UUID

    // MARK: - Constants

    static let availableInterests: [String] = [
        "カフェ", "サウナ", "写真", "音楽", "アート",
        "映画", "読書", "グルメ", "ワイン", "旅行",
        "アウトドア", "スポーツ", "ファッション", "ゲーム",
        "語学", "テック", "スタートアップ", "ヨガ"
    ]

    // MARK: - Computed Properties

    var canProceed: Bool {
        switch currentStep {
        case .basicInfo:
            return !profile.schoolOrWork.isEmpty
        case .interests:
            return selectedInterests.count >= 3 && selectedInterests.count <= 10
        case .photos:
            return profile.photos.count >= 1
        case .instagram:
            return true // 任意
        case .complete:
            return true
        }
    }

    var progressValue: Double {
        currentStep.progress
    }

    // MARK: - Initializer

    init(
        createProfileUseCase: CreateProfileUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        currentUserId: UUID
    ) {
        self.createProfileUseCase = createProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.currentUserId = currentUserId

        // 初期プロフィール
        self.profile = Profile(
            userId: currentUserId,
            ageRange: .range20_22,
            attribute: .student,
            schoolOrWork: "",
            district: "新宿区",
            nearestStation: "",
            interests: [],
            bio: nil,
            photos: [],
            photoOrder: []
        )
    }

    // MARK: - Actions

    /// 次へ進む
    @MainActor
    func proceedToNext() async {
        validationErrors = []
        errorMessage = nil

        // バリデーション
        guard canProceed else {
            errorMessage = "必須項目を入力してください"
            return
        }

        // 最終ステップの場合はプロフィール作成
        if currentStep == .instagram {
            await createProfile()
            return
        }

        // 次のステップへ
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }

    /// 前に戻る
    func goBack() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }

    /// 興味タグを選択/解除
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            if selectedInterests.count < 10 {
                selectedInterests.insert(interest)
            } else {
                errorMessage = "興味タグは最大10個まで選択できます"
            }
        }
    }

    /// 写真を追加
    func addPhoto(_ photoURL: String) {
        if profile.photos.count < 5 {
            profile.photos.append(photoURL)
            profile.photoOrder.append(photoURL)
            errorMessage = nil
        } else {
            errorMessage = "写真は最大5枚まで追加できます"
        }
    }

    /// 写真を削除
    func removePhoto(_ photoURL: String) {
        profile.photos.removeAll { $0 == photoURL }
        profile.photoOrder.removeAll { $0 == photoURL }
    }

    /// プロフィールを作成
    @MainActor
    private func createProfile() async {
        isLoading = true
        errorMessage = nil
        validationErrors = []

        // 興味タグを反映
        profile.interests = Array(selectedInterests)

        do {
            // プロフィール作成
            _ = try await createProfileUseCase.execute(profile)

            // 完了ステップへ
            currentStep = .complete
        } catch let error as ValidationError {
            validationErrors = [error.localizedDescription]
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Factory

extension OnboardingViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> OnboardingViewModel {
        let provider = RepositoryProvider.shared

        let createProfileUseCase = CreateProfileUseCase(
            profileRepository: provider.profileRepository
        )

        let updateProfileUseCase = UpdateProfileUseCase(
            profileRepository: provider.profileRepository
        )

        return OnboardingViewModel(
            createProfileUseCase: createProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
            currentUserId: currentUserId
        )
    }
}
