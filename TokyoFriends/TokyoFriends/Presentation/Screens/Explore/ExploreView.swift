import SwiftUI

/// 探索画面（カードスワイプ）
/// 画面ID: PG-30 - カード探索（0.4_ページ定義.md）
/// - カードデッキ
/// - スワイプジェスチャ（Like/Skip）
/// - マッチ成立シート
struct ExploreView: View {

    @Bindable var viewModel: ExploreViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var showFilterSheet = false
    @State private var showCardDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.bgBase.ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingView(message: "カードを読み込み中...")
                } else if let error = viewModel.error {
                    ErrorView(
                        error: error,
                        retryAction: {
                            Task {
                                await viewModel.loadCards()
                            }
                        }
                    )
                } else if viewModel.hasMoreCards {
                    cardDeck
                } else {
                    noMoreCardsView
                }
            }
            .navigationTitle("探索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showMatchSheet) {
                if let match = viewModel.newMatch {
                    MatchSuccessSheet(
                        match: match,
                        onDismiss: {
                            viewModel.dismissMatchSheet()
                        }
                    )
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(
                    filters: Binding(
                        get: { viewModel.filters ?? CardFilters() },
                        set: { viewModel.filters = $0 }
                    ),
                    onApply: {
                        showFilterSheet = false
                        Task {
                            await viewModel.loadCards()
                        }
                    },
                    onCancel: {
                        showFilterSheet = false
                    }
                )
            }
            .sheet(isPresented: $showCardDetail) {
                if let currentCard = viewModel.currentCard,
                   let profile = MockData.profiles.first(where: { $0.userId == currentCard.userId }) {
                    NavigationStack {
                        CardDetailView(
                            card: currentCard,
                            profile: profile,
                            onLike: {
                                showCardDetail = false
                                Task {
                                    await viewModel.sendLike()
                                }
                            },
                            onSkip: {
                                showCardDetail = false
                                Task {
                                    await viewModel.skip()
                                }
                            }
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    showCardDetail = false
                                }) {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadCards()
            }
        }
    }

    // MARK: - Card Deck

    private var cardDeck: some View {
        ZStack {
            // 次のカード（背景）
            if viewModel.currentCardIndex + 1 < viewModel.cards.count {
                let nextCard = viewModel.cards[viewModel.currentCardIndex + 1]
                if let profile = MockData.profiles.first(where: { $0.userId == nextCard.userId }) {
                    ProfileCardView(card: nextCard, profile: profile)
                        .padding(Spacing.l)
                        .scaleEffect(0.95)
                        .opacity(0.5)
                }
            }

            // 現在のカード
            if let currentCard = viewModel.currentCard,
               let profile = MockData.profiles.first(where: { $0.userId == currentCard.userId }) {
                ProfileCardView(card: currentCard, profile: profile)
                    .padding(Spacing.l)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(rotationAngle))
                    .onTapGesture {
                        showCardDetail = true
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                                rotationAngle = Double(value.translation.width / 20)
                            }
                            .onEnded { value in
                                handleSwipe(value.translation)
                            }
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragOffset)
            }
        }
        .overlay(alignment: .bottom) {
            actionButtons
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.xxl) {
            // Skipボタン
            Button(action: {
                Task {
                    await viewModel.skip()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(ColorTokens.textTertiary)
                    .clipShape(Circle())
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            }
            .accessibilityLabel("スキップ")

            // Likeボタン（パルスアニメーション付き）
            PulseButton(
                icon: "heart.fill",
                action: {
                    Task {
                        await viewModel.sendLike()
                    }
                },
                color: ColorTokens.accentPrimary,
                size: 70
            )
            .accessibilityLabel("Like")
        }
        .padding(.bottom, Spacing.xxl)
    }

    // MARK: - No More Cards

    private var noMoreCardsView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.accentSuccess)

            VStack(spacing: Spacing.s) {
                Text("すべてのカードを確認しました")
                    .font(Typography.headline)
                    .foregroundColor(ColorTokens.textPrimary)

                Text("新しい友達候補は随時追加されます")
                    .font(Typography.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(
                title: "更新",
                action: {
                    Task {
                        await viewModel.loadCards()
                    }
                },
                fullWidth: false
            )
            .padding(.horizontal, Spacing.xxl)
        }
        .padding(Spacing.l)
    }

    // MARK: - Swipe Handling

    private func handleSwipe(_ translation: CGSize) {
        let swipeThreshold: CGFloat = 100

        if translation.width > swipeThreshold {
            // 右スワイプ: Like
            Task {
                await viewModel.sendLike()
            }
        } else if translation.width < -swipeThreshold {
            // 左スワイプ: Skip
            Task {
                await viewModel.skip()
            }
        }

        // リセット
        withAnimation {
            dragOffset = .zero
            rotationAngle = 0
        }
    }
}

// MARK: - Match Success Sheet

struct MatchSuccessSheet: View {
    let match: Match
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // 成功アイコン
            ZStack {
                Circle()
                    .fill(ColorTokens.accentSuccess.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(ColorTokens.accentSuccess)
            }

            // メッセージ
            VStack(spacing: Spacing.m) {
                Text("マッチ成立！")
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorTokens.textPrimary)

                if let profile = match.partnerProfile {
                    Text("\(profile.schoolOrWork)さんとマッチしました")
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Instagramハンドル
            if let igHandle = match.partnerInstagramHandle {
                VStack(spacing: Spacing.s) {
                    Text("Instagramで繋がりましょう")
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)

                    HStack {
                        Image(systemName: "camera.circle.fill")
                            .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.58))

                        Text("@\(igHandle)")
                            .font(Typography.callout)
                            .foregroundColor(ColorTokens.textPrimary)
                    }
                    .padding(Spacing.m)
                    .background(ColorTokens.bgSection)
                    .cornerRadius(CornerRadius.card)
                }
            }

            Spacer()

            // ボタン
            VStack(spacing: Spacing.m) {
                if let instagramHandle = match.partnerInstagramHandle {
                    PrimaryButton(
                        title: "Instagramで開く",
                        action: {
                            openInstagram(handle: instagramHandle)
                            onDismiss()
                        }
                    )
                }

                SecondaryButton(
                    title: "閉じる",
                    action: onDismiss
                )
            }
            .padding(.horizontal, Spacing.l)

            Spacer()
                .frame(height: 50)
        }
        .background(ColorTokens.bgBase)
    }

    private func openInstagram(handle: String) {
        let instagramURL = URL(string: "instagram://user?username=\(handle)")
        let webURL = URL(string: "https://www.instagram.com/\(handle)")

        if let instagramURL = instagramURL, UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
        } else if let webURL = webURL {
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(viewModel: .make(currentUserId: MockData.currentUser.id))
            .previewDisplayName("Explore View")
    }
}
#endif
