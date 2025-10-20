import Foundation
import Observation

/// マッチ画面ViewModel
/// 画面ID: PG-40, PG-41 - マッチ一覧・詳細（0.4_ページ定義.md）
/// MVVM + Observation pattern（iOS 17+）
@Observable
final class MatchViewModel {

    // MARK: - Published State

    var matches: [Match] = []
    var selectedMatchDetail: MatchDetail?
    var isLoading: Bool = false
    var errorMessage: String?
    var showBlockConfirmation: Bool = false
    var matchToBlock: Match?

    // MARK: - Dependencies

    private let fetchMatchesUseCase: FetchMatchesUseCase
    private let blockUserUseCase: BlockUserUseCase
    private let currentUserId: UUID

    // MARK: - Computed Properties

    var hasMatches: Bool {
        !matches.isEmpty
    }

    // MARK: - Initializer

    init(
        fetchMatchesUseCase: FetchMatchesUseCase,
        blockUserUseCase: BlockUserUseCase,
        currentUserId: UUID
    ) {
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.blockUserUseCase = blockUserUseCase
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// マッチ一覧を読み込み
    @MainActor
    func loadMatches() async {
        isLoading = true
        errorMessage = nil

        do {
            matches = try await fetchMatchesUseCase.execute(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// マッチ詳細を読み込み
    @MainActor
    func loadMatchDetail(_ matchId: UUID) async {
        do {
            selectedMatchDetail = try await fetchMatchesUseCase.fetchDetail(
                matchId: matchId,
                requestingUserId: currentUserId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Instagramプロフィールを開く
    func openInstagramProfile(instagramHandle: String) {
        // instagram:// deep linkを試みる
        let deepLink = URL(string: "instagram://user?username=\(instagramHandle)")
        let webURL = URL(string: "https://instagram.com/\(instagramHandle)")

        #if canImport(UIKit)
        import UIKit
        if let deepLink = deepLink, UIApplication.shared.canOpenURL(deepLink) {
            UIApplication.shared.open(deepLink)
        } else if let webURL = webURL {
            UIApplication.shared.open(webURL)
        }
        #endif
    }

    /// ブロック確認ダイアログを表示
    func confirmBlock(_ match: Match) {
        matchToBlock = match
        showBlockConfirmation = true
    }

    /// ブロックを実行
    @MainActor
    func blockMatch() async {
        guard let match = matchToBlock else { return }

        // 相手のユーザーIDを特定
        let partnerUserId = match.userAId == currentUserId ? match.userBId : match.userAId

        do {
            try await blockUserUseCase.execute(
                blockingUserId: currentUserId,
                blockedUserId: partnerUserId
            )

            // マッチ一覧を再読み込み
            await loadMatches()

            // ダイアログを閉じる
            showBlockConfirmation = false
            matchToBlock = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// ブロック確認をキャンセル
    func cancelBlock() {
        showBlockConfirmation = false
        matchToBlock = nil
    }
}

// MARK: - Factory

extension MatchViewModel {
    /// デフォルトの依存性注入でViewModelを作成
    static func make(currentUserId: UUID) -> MatchViewModel {
        let provider = RepositoryProvider.shared

        let fetchMatchesUseCase = FetchMatchesUseCase(
            matchRepository: provider.matchRepository
        )

        let blockUserUseCase = BlockUserUseCase(
            userRepository: provider.userRepository,
            matchRepository: provider.matchRepository
        )

        return MatchViewModel(
            fetchMatchesUseCase: fetchMatchesUseCase,
            blockUserUseCase: blockUserUseCase,
            currentUserId: currentUserId
        )
    }
}
