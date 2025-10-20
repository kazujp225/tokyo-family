import SwiftUI

/// マッチ一覧画面
/// 画面ID: PG-40 - マッチ一覧（0.4_ページ定義.md）
/// - アクティブなマッチのリスト
/// - Instagram連携表示
/// - ブロック・通報機能
struct MatchListView: View {

    @Bindable var viewModel: MatchViewModel
    @State private var showReportSheet = false
    @State private var reportingMatch: MatchDetail?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasMatches {
                    matchList
                } else if viewModel.isLoading {
                    LoadingView(message: "マッチを読み込み中...")
                } else {
                    emptyState
                }
            }
            .background(ColorTokens.bgBase)
            .navigationTitle("マッチ")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadMatches()
            }
            .sheet(item: $viewModel.selectedMatchDetail) { matchDetail in
                MatchDetailSheet(
                    matchDetail: matchDetail,
                    onOpenInstagram: {
                        if let handle = matchDetail.match.partnerInstagramHandle {
                            viewModel.openInstagramProfile(instagramHandle: handle)
                        }
                    },
                    onBlock: {
                        viewModel.confirmBlock(matchDetail.match)
                    },
                    onReport: {
                        reportingMatch = matchDetail
                        showReportSheet = true
                    },
                    onDismiss: {
                        viewModel.selectedMatchDetail = nil
                    }
                )
            }
            .sheet(isPresented: $showReportSheet) {
                if let match = reportingMatch {
                    ReportUserView(
                        reportedUserId: match.partnerProfile.userId,
                        reportedUserName: match.partnerProfile.schoolOrWork
                    )
                }
            }
            .confirmationDialog(
                title: "ブロックしますか？",
                message: "ブロックすると、このユーザーとのマッチが解除され、今後カードに表示されなくなります。",
                confirmTitle: "ブロック",
                confirmRole: .destructive,
                isPresented: $viewModel.showBlockConfirmation,
                onConfirm: {
                    Task {
                        await viewModel.blockMatch()
                    }
                }
            )
            .task {
                await viewModel.loadMatches()
            }
        }
    }

    // MARK: - Match List

    private var matchList: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                ForEach(viewModel.matches) { match in
                    MatchRow(match: match)
                        .onTapGesture {
                            Task {
                                await viewModel.loadMatchDetail(match.id)
                            }
                        }
                }
            }
            .padding(Spacing.l)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "heart.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.textTertiary)

            VStack(spacing: Spacing.s) {
                Text("まだマッチがありません")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("探索タブでLikeを送ってみましょう")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.l)
    }
}

// MARK: - Match Row

struct MatchRow: View {
    let match: Match

    var body: some View {
        HStack(spacing: Spacing.m) {
            // アバター
            Circle()
                .fill(ColorTokens.bgSection)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(ColorTokens.textTertiary)
                )

            // プロフィール情報
            VStack(alignment: .leading, spacing: Spacing.xs) {
                if let profile = match.partnerProfile {
                    Text(profile.schoolOrWork)
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)

                    HStack(spacing: Spacing.xs) {
                        Text(profile.ageRange.displayText)
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.textSecondary)

                        Text("•")
                            .foregroundColor(ColorTokens.textSecondary)

                        Text(profile.district)
                            .font(Typography.footnote)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }

                // マッチ日時
                Text(match.matchedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption)
                    .foregroundColor(ColorTokens.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(ColorTokens.textTertiary)
        }
        .padding(Spacing.m)
        .background(ColorTokens.bgCard)
        .cornerRadius(CornerRadius.card)
    }
}

// MARK: - Match Detail Sheet

struct MatchDetailSheet: View {
    let matchDetail: MatchDetail
    let onOpenInstagram: () -> Void
    let onBlock: () -> Void
    let onReport: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // アバター
                    HStack {
                        Spacer()
                        Circle()
                            .fill(ColorTokens.bgSection)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(ColorTokens.textTertiary)
                            )
                        Spacer()
                    }

                    // プロフィール情報
                    VStack(alignment: .center, spacing: Spacing.s) {
                        Text(matchDetail.partnerProfile.schoolOrWork)
                            .font(Typography.largeTitle)
                            .foregroundColor(ColorTokens.textPrimary)

                        HStack(spacing: Spacing.xs) {
                            Text(matchDetail.partnerProfile.ageRange.displayText)
                                .font(Typography.body)
                                .foregroundColor(ColorTokens.textSecondary)

                            Text("•")
                                .foregroundColor(ColorTokens.textSecondary)

                            Text(matchDetail.partnerProfile.attribute.displayText)
                                .font(Typography.body)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // 詳細情報
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        DetailRow(
                            icon: "mappin.circle.fill",
                            title: "地域",
                            value: "\(matchDetail.partnerProfile.district) • \(matchDetail.partnerProfile.nearestStation)"
                        )

                        if let bio = matchDetail.partnerProfile.bio {
                            DetailRow(
                                icon: "text.alignleft",
                                title: "自己紹介",
                                value: bio
                            )
                        }
                    }

                    // 興味タグ
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("興味")
                            .font(Typography.caption)
                            .foregroundColor(ColorTokens.textSecondary)

                        FlowLayout(spacing: Spacing.xs) {
                            ForEach(matchDetail.partnerProfile.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(Typography.caption)
                                    .foregroundColor(ColorTokens.textSecondary)
                                    .padding(.horizontal, Spacing.s)
                                    .padding(.vertical, 4)
                                    .background(ColorTokens.secondarySystemFill)
                                    .cornerRadius(CornerRadius.chip)
                            }
                        }
                    }

                    Divider()

                    // Instagram
                    if let igHandle = matchDetail.match.partnerInstagramHandle {
                        VStack(spacing: Spacing.m) {
                            HStack {
                                Image(systemName: "camera.circle.fill")
                                    .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.58))

                                Text("@\(igHandle)")
                                    .font(Typography.callout)
                                    .foregroundColor(ColorTokens.textPrimary)

                                Spacer()
                            }
                            .padding(Spacing.m)
                            .background(ColorTokens.bgSection)
                            .cornerRadius(CornerRadius.card)

                            PrimaryButton(
                                title: "Instagramで開く",
                                action: onOpenInstagram
                            )
                        }
                    }

                    Spacer()
                }
                .padding(Spacing.l)
            }
            .background(ColorTokens.bgBase)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            onReport()
                        } label: {
                            Label("通報", systemImage: "exclamationmark.triangle")
                        }

                        Button(role: .destructive) {
                            onBlock()
                        } label: {
                            Label("ブロック", systemImage: "hand.raised.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout (for interest tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? 0
        let height = rows.last?.maxY ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            guard let row = rows.first(where: { $0.indices.contains(index) }) else { continue }
            let position = CGPoint(
                x: bounds.minX + row.xOffsets[row.indices.firstIndex(of: index)!],
                y: bounds.minY + row.minY
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        var y: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > (proposal.width ?? 0) && !currentRow.indices.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
                y += (rows.last?.height ?? 0) + spacing
            }

            currentRow.indices.append(subviews.firstIndex(where: { $0.id == subview.id })!)
            currentRow.xOffsets.append(x)
            currentRow.minY = y
            currentRow.height = max(currentRow.height, size.height)
            x += size.width + spacing
        }

        if !currentRow.indices.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private struct Row {
        var indices: [Int] = []
        var xOffsets: [CGFloat] = []
        var minY: CGFloat = 0
        var height: CGFloat = 0
        var maxY: CGFloat { minY + height }
    }
}

// MARK: - Preview

#if DEBUG
struct MatchListView_Previews: PreviewProvider {
    static var previews: some View {
        MatchListView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Match List View")
    }
}
#endif
