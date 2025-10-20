import SwiftUI

/// ホーム画面
/// 画面ID: PG-10 - ホーム（0.4_ページ定義.md）
/// - Large Title
/// - Hero（おすすめカード）
/// - マイコミュニティ
/// - 最近のマッチ
struct HomeView: View {

    @Bindable var viewModel: HomeViewModel
    @State private var selectedCard: CardSelection?
    @State private var selectedMatch: Match?
    @State private var navigateToMatchList = false
    @State private var navigateToCommunityList = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    if viewModel.isLoading {
                        // ローディングプレースホルダー（シマー効果）
                        loadingPlaceholders
                    } else {
                        // Hero: おすすめカード
                        if viewModel.hasRecommendations {
                            heroSection
                        }

                        // マイコミュニティ
                        if viewModel.hasCommunities {
                            communitiesSection
                        }

                        // 最近のマッチ
                        if viewModel.hasMatches {
                            matchesSection
                        }

                        // 空状態
                        if !viewModel.hasRecommendations && !viewModel.hasCommunities && !viewModel.hasMatches {
                            emptyState
                        }
                    }
                }
                .padding(.vertical, Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("Tokyo Friends")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadHomeData()
            }
            .task {
                await viewModel.loadHomeData()
            }
            .sheet(item: $selectedCard) { cardInfo in
                CardDetailView(
                    card: cardInfo.card,
                    profile: cardInfo.profile,
                    viewModel: .make(
                        currentUserId: viewModel.currentUserId,
                        targetUserId: cardInfo.card.userId
                    )
                )
            }
            .sheet(item: $selectedMatch) { match in
                MatchDetailView(
                    match: match,
                    viewModel: .make(match: match)
                )
            }
            .navigationDestination(isPresented: $navigateToMatchList) {
                MatchListView(
                    viewModel: .make(currentUserId: viewModel.currentUserId)
                )
            }
            .navigationDestination(isPresented: $navigateToCommunityList) {
                CommunityListView(
                    viewModel: .make(currentUserId: viewModel.currentUserId)
                )
            }
        }
    }

    // MARK: - Loading Placeholders

    private var loadingPlaceholders: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Hero placeholder
            VStack(alignment: .leading, spacing: Spacing.m) {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(ColorTokens.secondarySystemFill)
                    .frame(width: 150, height: 24)
                    .shimmer(isLoading: true)
                    .padding(.horizontal, Spacing.l)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.m) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: CornerRadius.card)
                                .fill(ColorTokens.secondarySystemFill)
                                .frame(width: 280, height: 360)
                                .shimmer(isLoading: true)
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                }
            }

            // Communities placeholder
            VStack(alignment: .leading, spacing: Spacing.m) {
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(ColorTokens.secondarySystemFill)
                    .frame(width: 180, height: 24)
                    .shimmer(isLoading: true)
                    .padding(.horizontal, Spacing.l)

                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .fill(ColorTokens.secondarySystemFill)
                        .frame(height: 80)
                        .shimmer(isLoading: true)
                        .padding(.horizontal, Spacing.l)
                }
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("今日のおすすめ")
                .font(Typography.title2)
                .foregroundColor(ColorTokens.textPrimary)
                .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.m) {
                    ForEach(viewModel.recommendedCards) { card in
                        if let profile = MockData.profiles.first(where: { $0.userId == card.userId }) {
                            ProfileCardView(card: card, profile: profile)
                                .frame(width: 280)
                                .onTapGesture {
                                    selectedCard = CardSelection(card: card, profile: profile)
                                }
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    // MARK: - Communities Section

    private var communitiesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Text("マイコミュニティ")
                    .font(Typography.title2)
                    .foregroundColor(ColorTokens.textPrimary)

                Spacer()

                Button("すべて表示") {
                    navigateToCommunityList = true
                }
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textLink)
            }
            .padding(.horizontal, Spacing.l)

            VStack(spacing: Spacing.m) {
                ForEach(viewModel.userCommunities.prefix(3)) { community in
                    NavigationLink(destination: CommunityDetailView(
                        viewModel: .make(
                            communityId: community.id,
                            currentUserId: viewModel.currentUserId
                        )
                    )) {
                        CommunityCardView(
                            community: community,
                            isJoined: true,
                            onTap: {}
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    // MARK: - Matches Section

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Text("最近のマッチ")
                    .font(Typography.title2)
                    .foregroundColor(ColorTokens.textPrimary)

                Spacer()

                Button("すべて表示") {
                    navigateToMatchList = true
                }
                .font(Typography.footnote)
                .foregroundColor(ColorTokens.textLink)
            }
            .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.m) {
                    ForEach(viewModel.recentMatches) { match in
                        matchThumbnail(match)
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    private func matchThumbnail(_ match: Match) -> some View {
        VStack(spacing: Spacing.xs) {
            // アバター
            Circle()
                .fill(ColorTokens.bgSection)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundColor(ColorTokens.textTertiary)
                )

            // 名前（学校/職場）
            if let profile = match.partnerProfile {
                Text(profile.schoolOrWork)
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textPrimary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
        }
        .onTapGesture {
            selectedMatch = match
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "person.2.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(ColorTokens.textTertiary)

            VStack(spacing: Spacing.s) {
                Text("さあ、始めましょう！")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("探索タブから友達を探してみましょう")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.l)
    }
}

// MARK: - Helper Types

private struct CardSelection: Identifiable {
    let id: UUID
    let card: Card
    let profile: Profile

    init(card: Card, profile: Profile) {
        self.id = card.id
        self.card = card
        self.profile = profile
    }
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Home View")

        HomeView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .preferredColorScheme(.dark)
            .previewDisplayName("Home View - Dark")
    }
}
#endif
