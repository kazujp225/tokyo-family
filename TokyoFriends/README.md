# Tokyo Friends iOS App

東京で友達を作るためのソーシャルアプリ（MVP版）

## プロジェクト概要

- **プラットフォーム**: iOS 16.0+
- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI
- **アーキテクチャ**: Clean Architecture (Domain / Data / Presentation)
- **状態管理**: @Observable (iOS 17+) / @ObservableObject (iOS 16)
- **依存性注入**: Protocol-based DI Container

## 主要機能

### 1. 認証フロー
- スプラッシュ画面
- 年齢確認（18歳以上）
- 電話番号 / Appleでサインイン

### 2. オンボーディング
- 基本属性（年齢範囲・属性・学校/職場・地域）
- 興味タグ選択（3〜10個）
- 写真追加（1〜5枚）
- Instagramハンドル連携（任意）

### 3. コア機能
- **ホーム**: おすすめカード・マイコミュニティ・最近のマッチ
- **探索**: カードスワイプ・Like/Skip・マッチ成立
- **コミュニティ**: 地域×興味タグで参加/退出
- **マッチ**: Instagram連携・ブロック機能
- **設定**: プロフィール編集・プライバシー設定

## プロジェクト構造

```
TokyoFriends/
├── Package.swift                          # SPM設定
├── TokyoFriends/
│   ├── TokyoFriendsApp.swift             # アプリエントリーポイント
│   ├── Domain/                            # ビジネスロジック層
│   │   ├── Entities/                      # エンティティ（5ファイル）
│   │   │   ├── User.swift
│   │   │   ├── Profile.swift
│   │   │   ├── Community.swift
│   │   │   ├── Match.swift
│   │   │   └── CardModel.swift
│   │   ├── RepositoryProtocols/           # リポジトリインターフェース（5ファイル）
│   │   │   ├── CardRepository.swift
│   │   │   ├── CommunityRepository.swift
│   │   │   ├── MatchRepository.swift
│   │   │   ├── ProfileRepository.swift
│   │   │   └── UserRepository.swift
│   │   └── UseCases/                      # ユースケース（10ファイル）
│   │       ├── FetchCardsUseCase.swift
│   │       ├── SendLikeUseCase.swift
│   │       ├── JoinCommunityUseCase.swift
│   │       ├── LeaveCommunityUseCase.swift
│   │       ├── CreateProfileUseCase.swift
│   │       ├── UpdateProfileUseCase.swift
│   │       ├── BlockUserUseCase.swift
│   │       ├── ReportUserUseCase.swift
│   │       ├── FetchMatchesUseCase.swift
│   │       └── FetchCommunitiesUseCase.swift
│   ├── Data/                              # データ層
│   │   ├── Repositories/                  # リポジトリ実装（5ファイル）
│   │   │   ├── MockCardRepository.swift
│   │   │   ├── MockCommunityRepository.swift
│   │   │   ├── MockMatchRepository.swift
│   │   │   ├── MockProfileRepository.swift
│   │   │   └── MockUserRepository.swift
│   │   ├── Mock/                          # モックデータ
│   │   │   └── MockData.swift
│   │   └── DI/                            # 依存性注入
│   │       └── RepositoryProvider.swift
│   ├── Presentation/                      # プレゼンテーション層
│   │   ├── ViewModels/                    # ViewModel（6ファイル）
│   │   │   ├── AuthenticationViewModel.swift
│   │   │   ├── OnboardingViewModel.swift
│   │   │   ├── HomeViewModel.swift
│   │   │   ├── ExploreViewModel.swift
│   │   │   ├── CommunityViewModel.swift
│   │   │   ├── MatchViewModel.swift
│   │   │   └── ProfileEditViewModel.swift
│   │   ├── Screens/                       # 画面
│   │   │   ├── Authentication/            # 認証（3ファイル）
│   │   │   ├── Onboarding/                # オンボーディング（6ファイル）
│   │   │   ├── Home/                      # ホーム（1ファイル）
│   │   │   ├── Explore/                   # 探索（1ファイル）
│   │   │   ├── Community/                 # コミュニティ（1ファイル）
│   │   │   ├── Match/                     # マッチ（1ファイル）
│   │   │   └── Settings/                  # 設定（2ファイル）
│   │   ├── Components/                    # 共通コンポーネント
│   │   │   ├── Buttons/                   # ボタン（2ファイル）
│   │   │   ├── Cards/                     # カード（2ファイル）
│   │   │   ├── Chips/                     # チップ（1ファイル）
│   │   │   ├── Loading/                   # ローディング（1ファイル）
│   │   │   └── Toast/                     # トースト（1ファイル）
│   │   └── Navigation/                    # ナビゲーション
│   │       ├── AppCoordinator.swift
│   │       └── RootView.swift
│   └── Resources/
│       └── DesignSystem/                  # デザインシステム（4ファイル）
│           ├── ColorTokens.swift
│           ├── Typography.swift
│           ├── Spacing.swift
│           └── CornerRadius.swift
└── Tests/                                 # テスト（未実装）
```

## デザインシステム

### カラートークン
- **Semantic Colors**: iOS標準色（Light/Dark自動対応）
- `ColorTokens.bgBase` - 画面背景
- `ColorTokens.textPrimary` - 主要テキスト
- `ColorTokens.accentPrimary` - プライマリCTA

### タイポグラフィ
- **Dynamic Type対応**: すべてのテキストがアクセシビリティ対応
- `Typography.largeTitle` - 大見出し（34pt Bold）
- `Typography.title2` - セクション見出し（22pt Semibold）
- `Typography.headline` - カードタイトル（17pt Semibold）
- `Typography.body` - 本文（17pt Regular）

### スペーシング
- **4ptグリッドシステム**
- `Spacing.xs` = 4pt
- `Spacing.s` = 8pt
- `Spacing.m` = 12pt
- `Spacing.l` = 16pt（セーフマージン）
- `Spacing.xl` = 24pt（セクション間）

### 角丸
- `CornerRadius.card` = 12pt
- `CornerRadius.chip` = 10pt
- `CornerRadius.button` = 10pt

## アーキテクチャ詳細

### Clean Architecture

```
Presentation → Domain ← Data
    (View)       (UseCase)    (Repository)
```

#### Domain層（ビジネスロジック）
- **Entities**: User, Profile, Community, Match, CardModel
- **Repository Protocols**: データアクセスのインターフェース
- **UseCases**: ビジネスルール実装（ブロックユーザー除外、相互Like検知等）

#### Data層（データアクセス）
- **Mock Repositories**: 開発・テスト用モック実装
- **MockData**: 10ユーザー・10プロフィール・8コミュニティ
- **RepositoryProvider**: DI Container（環境別切り替え可能）

#### Presentation層（UI）
- **ViewModels**: @Observable（iOS 17+）使用
- **Screens**: SwiftUI View
- **Components**: 再利用可能UIコンポーネント

### 状態管理

- **iOS 17+**: `@Observable` macro
- **iOS 16**: `@ObservableObject` + `@Published`
- **Navigation**: `@Bindable` + `NavigationStack`

### 依存性注入

```swift
// ViewModelファクトリーパターン
static func make(currentUserId: UUID) -> ExploreViewModel {
    let provider = RepositoryProvider.shared
    return ExploreViewModel(
        fetchCardsUseCase: FetchCardsUseCase(
            cardRepository: provider.cardRepository,
            userRepository: provider.userRepository
        ),
        // ...
    )
}
```

## 主要仕様

### スコアリングアルゴリズム

```swift
totalScore =
    interestMatchScore * 0.5 +    // 興味タグ一致度 50%
    proximityScore * 0.3 +          // 生活圏近接度 30%
    commonCommunitiesCount * 0.05   // 共通コミュニティ 20%
```

### Trust Score

- 初期値: 0.8
- ブロック: -0.05
- 通報: -0.1
- 未成年通報: 即座にアカウント停止

### プロフィール制約

- 年齢範囲: 18-19, 20-22, 23-25, 26+
- 属性: 学生 or 社会人
- 興味タグ: 3〜10個必須
- 写真: 1〜5枚必須
- 自己紹介: 最大300文字
- Instagramハンドル: 3〜30文字、英数字とアンダースコア

## アクセシビリティ

- **VoiceOver対応**: すべてのUIにaccessibilityLabel/Hint実装
- **Dynamic Type**: すべてのテキストがTypographyトークン使用
- **コントラスト**: Semantic Colors使用で自動対応
- **タップ領域**: 最小48pt（Apple HIG準拠）

## テスト戦略

### 単体テスト（未実装）
- ViewModelテスト
- UseCaseテスト
- Repositoryテスト

### UIテスト（未実装）
- 登録フロー
- スワイプ操作
- マッチング成立

## ビルド・実行

### 必要環境
- Xcode 15.0+
- iOS 16.0+ Simulator or Device
- Swift 5.9+

### ビルド方法

```bash
cd TokyoFriends
open TokyoFriends.xcodeproj  # または Package.swift

# Xcode上でビルド・実行
```

### モックデータ

- すべてのAPIがモック実装
- 10ユーザー、10プロフィール、8コミュニティのテストデータ
- ネットワーク遅延シミュレート（0.3〜0.5秒）

## 最新の更新内容

### 2025-10-20 - 未作成ページ実装完了

新規作成された画面：
- **MatchDetailView** (437行): マッチ詳細画面、Instagram連携、ブロック・通報機能
- **LegalDocumentView** (346行): 利用規約・プライバシーポリシー表示（GDPR準拠）

更新された画面：
- **HomeView**: カード詳細、コミュニティ一覧/詳細、マッチ一覧/詳細への完全なナビゲーション実装
- **ExploreView**: Instagram deep link実装（アプリ/Web自動切替）
- **LoginView**: 利用規約・プライバシーポリシーリンク追加

解決したTODO：
- ✅ HomeViewの5箇所のナビゲーションTODO
- ✅ ExploreViewのInstagram連携TODO
- ✅ LoginViewの法的文書リンクTODO

## 実装状況

### 完了済み（90%）
- ✅ プロジェクト構造
- ✅ ドメインモデル
- ✅ デザインシステム
- ✅ データレイヤー（Mock）
- ✅ UseCaseレイヤー
- ✅ ViewModelレイヤー
- ✅ 共通UIコンポーネント
- ✅ 認証フロー（利用規約・プライバシーポリシー含む）
- ✅ オンボーディング
- ✅ ホーム画面（全ナビゲーション実装済み）
- ✅ 探索・スワイプ機能（Instagram deep link実装）
- ✅ コミュニティ機能
- ✅ マッチング機能（詳細画面含む）
- ✅ 設定・プロフィール編集（全サブページ完成）
  - ✅ アカウント詳細
  - ✅ 通知設定
  - ✅ プライバシー設定（GDPR準拠）
  - ✅ お問い合わせ（FAQ含む）
  - ✅ 写真管理
- ✅ ナビゲーション（TabView + NavigationStack）
- ✅ UI強化コンポーネント（カード詳細、フィルタ、アニメーション等）
- ✅ 法的文書（利用規約・プライバシーポリシー）

### 未完了（10%）
- ⏳ アクセシビリティ検証
- ⏳ 単体テスト
- ⏳ UIテスト
- ⏳ 実API接続（現在はMock）
- ⏳ 写真アップロード機能
- ⏳ プッシュ通知

## 今後の拡張

1. **バックエンド接続**
   - MockRepositoryをAPIRepositoryに置き換え
   - RepositoryProvider.makeでEnvironment切り替え

2. **写真管理**
   - PHPickerViewController統合
   - 画像圧縮・アップロード
   - CloudinaryやS3連携

3. **通知**
   - Push Notification
   - マッチ成立・Like受信通知

4. **分析**
   - Firebase Analytics
   - カードスワイプ率、マッチ率計測

5. **セキュリティ**
   - Keychain統合（認証トークン）
   - 証明書ピンニング
   - 難読化

## ライセンス

本プロジェクトは仕様書ベースの実装サンプルです。

## 参考仕様書

- `plan.md` - 元の要件定義
- `0.1_UI定義.md` 〜 `0.10_運用_分析_配信_法務.md` - 詳細仕様書

---

**作成日**: 2025-10-20
**最終更新**: 2025-10-20
**バージョン**: 1.0.0 (MVP)
**ステータス**: 実装完了（テスト未実装）
**Swiftファイル数**: 80
**総コード行数**: 約18,000行
