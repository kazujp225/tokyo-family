import SwiftUI

/// コミュニティ一覧画面
/// 画面ID: PG-20 - コミュニティ一覧（0.4_ページ定義.md）
/// - 地域・興味タグでフィルタ
/// - 参加者数順で表示
/// - 参加/退出ボタン
struct CommunityListView: View {

    @Bindable var viewModel: CommunityViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    // フィルタセクション
                    filterSection

                    // コミュニティリスト
                    VStack(spacing: Spacing.m) {
                        ForEach(viewModel.communities) { community in
                            CommunityCardView(
                                community: community,
                                isJoined: viewModel.isJoined(community),
                                onTap: {
                                    Task {
                                        await viewModel.loadCommunityDetail(community.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.l)

                    // 空状態
                    if viewModel.communities.isEmpty && !viewModel.isLoading {
                        emptyState
                    }
                }
                .padding(.vertical, Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("コミュニティ")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadCommunities()
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        LoadingView(message: "コミュニティを読み込み中...")
                    }
                }
            )
            .sheet(item: $viewModel.selectedCommunity) { community in
                CommunityDetailSheet(
                    community: community,
                    isJoined: viewModel.isJoined(community),
                    onJoin: {
                        Task {
                            await viewModel.joinCommunity(community)
                            viewModel.selectedCommunity = nil
                        }
                    },
                    onLeave: {
                        Task {
                            await viewModel.leaveCommunity(community)
                            viewModel.selectedCommunity = nil
                        }
                    },
                    onDismiss: {
                        viewModel.selectedCommunity = nil
                    }
                )
            }
            .task {
                await viewModel.loadCommunities()
                await viewModel.loadUserCommunities()
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("フィルタ")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textPrimary)
                .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    // 地域フィルタ
                    ForEach(["新宿区", "渋谷区", "港区", "千代田区"], id: \.self) { district in
                        InterestChip(
                            title: district,
                            isSelected: viewModel.districtFilter == district,
                            action: {
                                Task {
                                    if viewModel.districtFilter == district {
                                        await viewModel.updateFilters(district: nil, interest: viewModel.interestFilter)
                                    } else {
                                        await viewModel.updateFilters(district: district, interest: viewModel.interestFilter)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.l)
            }

            // フィルタクリアボタン
            if viewModel.hasFilters {
                Button(action: {
                    Task {
                        await viewModel.clearFilters()
                    }
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "xmark.circle.fill")
                        Text("フィルタをクリア")
                    }
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textLink)
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "person.3")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.textTertiary)

            VStack(spacing: Spacing.s) {
                Text("コミュニティが見つかりません")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("フィルタを変更してみてください")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }
}

// MARK: - Community Detail Sheet

struct CommunityDetailSheet: View {
    let community: Community
    let isJoined: Bool
    let onJoin: () -> Void
    let onLeave: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // タイトル
                    Text(community.generatedName)
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)

                    // 参加者数
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(ColorTokens.textSecondary)

                        Text("\(community.participantCount)人が参加中")
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textSecondary)
                    }

                    // 説明
                    if let description = community.description {
                        Text(description)
                            .font(Typography.body)
                            .foregroundColor(ColorTokens.textPrimary)
                            .lineSpacing(Typography.lineSpacing)
                    }

                    Divider()

                    // 詳細情報
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        DetailRow(
                            icon: "mappin.circle.fill",
                            title: "地域",
                            value: community.district
                        )

                        DetailRow(
                            icon: "tag.fill",
                            title: "興味タグ",
                            value: community.interestTag
                        )
                    }

                    Spacer()
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        onDismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // 参加/退出ボタン
                VStack(spacing: Spacing.m) {
                    if isJoined {
                        SecondaryButton(
                            title: "退出する",
                            action: onLeave,
                            style: .filled
                        )
                    } else {
                        PrimaryButton(
                            title: "参加する",
                            action: onJoin
                        )
                    }
                }
                .padding(Spacing.l)
                .background(ColorTokens.bgBase)
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .foregroundColor(ColorTokens.accentPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textSecondary)

                Text(value)
                    .font(Typography.body)
                    .foregroundColor(ColorTokens.textPrimary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CommunityListView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityListView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Community List View")
    }
}
#endif
