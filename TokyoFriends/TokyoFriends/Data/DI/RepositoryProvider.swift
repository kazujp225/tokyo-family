import Foundation

/// リポジトリプロバイダー（Dependency Injection Container）
/// Clean Architectureの依存性注入を管理
/// - Note: 本番環境ではAPIリポジトリに差し替え可能
final class RepositoryProvider {

    // MARK: - Singleton

    static let shared = RepositoryProvider()

    // MARK: - Repositories

    let cardRepository: CardRepository
    let communityRepository: CommunityRepository
    let matchRepository: MatchRepository
    let profileRepository: ProfileRepository
    let userRepository: UserRepository

    // MARK: - Initializer

    private init() {
        // モックリポジトリを初期化
        // 本番環境では環境変数やビルド設定で切り替え
        self.cardRepository = MockCardRepository()
        self.communityRepository = MockCommunityRepository()
        self.matchRepository = MockMatchRepository()
        self.profileRepository = MockProfileRepository()
        self.userRepository = MockUserRepository()
    }

    // MARK: - Factory (テスト用)

    /// テスト用のプロバイダーを作成
    /// - Parameters:
    ///   - cardRepository: カスタムCardRepository（nilの場合はMock使用）
    ///   - communityRepository: カスタムCommunityRepository（nilの場合はMock使用）
    ///   - matchRepository: カスタムMatchRepository（nilの場合はMock使用）
    ///   - profileRepository: カスタムProfileRepository（nilの場合はMock使用）
    ///   - userRepository: カスタムUserRepository（nilの場合はMock使用）
    /// - Returns: テスト用RepositoryProvider
    static func makeForTesting(
        cardRepository: CardRepository? = nil,
        communityRepository: CommunityRepository? = nil,
        matchRepository: MatchRepository? = nil,
        profileRepository: ProfileRepository? = nil,
        userRepository: UserRepository? = nil
    ) -> RepositoryProvider {
        let provider = RepositoryProvider()

        // カスタムリポジトリが提供されている場合は差し替え
        // （リフレクションやプロトコル指向の依存注入を使用して実装）
        // 現状はモック実装のみなので、将来の拡張性のためにシグネチャのみ定義

        return provider
    }
}

// MARK: - Environment-based Configuration

extension RepositoryProvider {
    /// 環境設定に基づいてリポジトリを初期化
    /// - Parameter environment: 環境（Development / Staging / Production）
    /// - Returns: 環境に応じたRepositoryProvider
    static func make(for environment: AppEnvironment) -> RepositoryProvider {
        switch environment {
        case .development:
            // 開発環境: モックリポジトリを使用
            return RepositoryProvider.shared

        case .staging:
            // ステージング環境: 本番APIを使用（将来実装）
            // return RepositoryProvider(useAPI: true, baseURL: "https://staging.api.tokyofriends.app")
            return RepositoryProvider.shared

        case .production:
            // 本番環境: 本番APIを使用（将来実装）
            // return RepositoryProvider(useAPI: true, baseURL: "https://api.tokyofriends.app")
            return RepositoryProvider.shared
        }
    }
}

// MARK: - App Environment

/// アプリ環境
enum AppEnvironment {
    case development
    case staging
    case production

    /// 現在の環境を取得（ビルド設定から判定）
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
