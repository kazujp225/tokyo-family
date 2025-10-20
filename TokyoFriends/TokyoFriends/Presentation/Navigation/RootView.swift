import SwiftUI

/// ルートビュー（アプリのエントリーポイント）
/// 認証状態に応じて表示を切り替える
struct RootView: View {

    @State private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            switch coordinator.authViewModel.authState {
            case .splash:
                SplashView(viewModel: coordinator.authViewModel)

            case .ageGate:
                AgeGateView(viewModel: coordinator.authViewModel)

            case .login:
                LoginView(viewModel: coordinator.authViewModel)

            case .onboarding:
                if let userId = coordinator.currentUserId {
                    OnboardingContainerView(
                        viewModel: .make(currentUserId: userId),
                        onComplete: {
                            coordinator.authViewModel.completeOnboarding()
                        }
                    )
                }

            case .authenticated:
                if let userId = coordinator.currentUserId {
                    MainTabView(coordinator: coordinator, userId: userId)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.authViewModel.authState)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {

    @Bindable var coordinator: AppCoordinator
    let userId: UUID

    // ViewModels
    @State private var homeViewModel: HomeViewModel?
    @State private var exploreViewModel: ExploreViewModel?
    @State private var communityViewModel: CommunityViewModel?
    @State private var matchViewModel: MatchViewModel?
    @State private var profileViewModel: ProfileEditViewModel?

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // ホーム
            if let homeViewModel = homeViewModel {
                HomeView(viewModel: homeViewModel)
                    .tabItem {
                        Label(
                            AppCoordinator.Tab.home.title,
                            systemImage: coordinator.selectedTab == .home
                                ? AppCoordinator.Tab.home.iconFilled
                                : AppCoordinator.Tab.home.icon
                        )
                    }
                    .tag(AppCoordinator.Tab.home)
            }

            // 探索
            if let exploreViewModel = exploreViewModel {
                ExploreView(viewModel: exploreViewModel)
                    .tabItem {
                        Label(
                            AppCoordinator.Tab.explore.title,
                            systemImage: coordinator.selectedTab == .explore
                                ? AppCoordinator.Tab.explore.iconFilled
                                : AppCoordinator.Tab.explore.icon
                        )
                    }
                    .tag(AppCoordinator.Tab.explore)
            }

            // コミュニティ
            if let communityViewModel = communityViewModel {
                CommunityListView(viewModel: communityViewModel)
                    .tabItem {
                        Label(
                            AppCoordinator.Tab.community.title,
                            systemImage: coordinator.selectedTab == .community
                                ? AppCoordinator.Tab.community.iconFilled
                                : AppCoordinator.Tab.community.icon
                        )
                    }
                    .tag(AppCoordinator.Tab.community)
            }

            // マッチ
            if let matchViewModel = matchViewModel {
                MatchListView(viewModel: matchViewModel)
                    .tabItem {
                        Label(
                            AppCoordinator.Tab.matches.title,
                            systemImage: coordinator.selectedTab == .matches
                                ? AppCoordinator.Tab.matches.iconFilled
                                : AppCoordinator.Tab.matches.icon
                        )
                    }
                    .tag(AppCoordinator.Tab.matches)
                    .badge(matchViewModel.matches.count)
            }

            // 設定
            if let profileViewModel = profileViewModel {
                SettingsView(profileViewModel: profileViewModel)
                    .tabItem {
                        Label(
                            AppCoordinator.Tab.settings.title,
                            systemImage: coordinator.selectedTab == .settings
                                ? AppCoordinator.Tab.settings.iconFilled
                                : AppCoordinator.Tab.settings.icon
                        )
                    }
                    .tag(AppCoordinator.Tab.settings)
            }
        }
        .onAppear {
            // ViewModelsを初期化（1回のみ）
            if homeViewModel == nil {
                homeViewModel = .make(currentUserId: userId)
                exploreViewModel = .make(currentUserId: userId)
                communityViewModel = .make(currentUserId: userId)
                matchViewModel = .make(currentUserId: userId)
                profileViewModel = .make(currentUserId: userId)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .previewDisplayName("Root View")
    }
}
#endif
