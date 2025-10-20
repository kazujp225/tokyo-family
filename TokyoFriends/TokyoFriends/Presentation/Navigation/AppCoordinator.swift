import SwiftUI
import Observation

/// アプリ全体のナビゲーションコーディネーター
/// - 認証状態管理
/// - タブ切り替え
/// - Deep Link処理
@Observable
final class AppCoordinator {

    // MARK: - Published State

    var authViewModel: AuthenticationViewModel
    var selectedTab: Tab = .home

    // MARK: - Tab Definition

    enum Tab: Int, CaseIterable {
        case home = 0
        case explore = 1
        case community = 2
        case matches = 3
        case settings = 4

        var title: String {
            switch self {
            case .home: return "ホーム"
            case .explore: return "探索"
            case .community: return "コミュニティ"
            case .matches: return "マッチ"
            case .settings: return "設定"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .explore: return "sparkles"
            case .community: return "person.3"
            case .matches: return "heart"
            case .settings: return "gearshape"
            }
        }

        var iconFilled: String {
            switch self {
            case .home: return "house.fill"
            case .explore: return "sparkles"
            case .community: return "person.3.fill"
            case .matches: return "heart.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    // MARK: - Computed Properties

    var isAuthenticated: Bool {
        authViewModel.authState == .authenticated
    }

    var currentUserId: UUID? {
        authViewModel.currentUser?.id
    }

    // MARK: - Initializer

    init() {
        self.authViewModel = .make()
    }

    // MARK: - Actions

    /// タブを選択
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }

    /// ログアウト
    func logout() {
        authViewModel.authState = .login
        authViewModel.currentUser = nil
    }
}
