import Foundation
import Observation

/// 認証ViewModel
/// 画面ID: PG-01〜03 - Splash/Login/Age Gate（0.4_ページ定義.md）
/// 機能ID: F-09 - 年齢認証（0.3_機能定義.md）
@Observable
final class AuthenticationViewModel {

    // MARK: - Published State

    var authState: AuthState = .splash
    var isLoading: Bool = false
    var errorMessage: String?
    var isOver18: Bool = false

    // MARK: - Auth State

    enum AuthState {
        case splash           // スプラッシュ画面
        case ageGate          // 年齢確認
        case login            // ログイン選択
        case onboarding       // オンボーディング
        case authenticated    // 認証済み（ホームへ）
    }

    // MARK: - Dependencies

    private let userRepository: UserRepository

    // MARK: - Current User

    var currentUser: User?

    // MARK: - Initializer

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // MARK: - Actions

    /// スプラッシュ画面を表示後、認証状態をチェック
    @MainActor
    func checkAuthenticationStatus() async {
        // シミュレート: スプラッシュ表示時間（2秒）
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // TODO: 実際はKeychain/UserDefaultsから認証状態を確認
        // 現在はモックなので年齢確認へ遷移
        authState = .ageGate
    }

    /// 年齢確認を完了
    @MainActor
    func confirmAge(isOver18: Bool) async {
        self.isOver18 = isOver18

        if isOver18 {
            // 18歳以上: ログイン画面へ
            authState = .login
        } else {
            // 18歳未満: エラーメッセージ表示
            errorMessage = "Tokyo Friendsは18歳以上の方のみご利用いただけます。"
        }
    }

    /// 電話番号でログイン
    @MainActor
    func loginWithPhone() async {
        isLoading = true
        errorMessage = nil

        // シミュレート: 電話番号認証
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒

        do {
            // ユーザー作成
            let user = try await userRepository.createUser(
                authMethod: .phone,
                isOver18: isOver18
            )

            currentUser = user

            // プロフィールが未作成の場合はオンボーディングへ
            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Appleでログイン
    @MainActor
    func loginWithApple() async {
        isLoading = true
        errorMessage = nil

        // シミュレート: Apple認証
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒

        do {
            // ユーザー作成
            let user = try await userRepository.createUser(
                authMethod: .apple,
                isOver18: isOver18
            )

            currentUser = user

            // プロフィールが未作成の場合はオンボーディングへ
            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// オンボーディング完了
    func completeOnboarding() {
        authState = .authenticated
    }
}

// MARK: - Factory

extension AuthenticationViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make() -> AuthenticationViewModel {
        let provider = RepositoryProvider.shared

        return AuthenticationViewModel(
            userRepository: provider.userRepository
        )
    }
}
