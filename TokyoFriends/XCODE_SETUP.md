# Tokyo Friends - Xcodeセットアップガイド

## 🎯 Xcodeでプロジェクトを開く方法

このプロジェクトはSwift Package Manager (SPM)ベースのiOSアプリケーションです。

### 方法1: Package.swiftから直接開く（推奨）

1. Xcodeを起動
2. `File` → `Open...` を選択
3. `Package.swift` ファイルを選択して開く
4. Xcodeが自動的にプロジェクト構成を読み込みます

```bash
# ターミナルから開く場合
open -a Xcode Package.swift
```

### 方法2: Xcodeプロジェクトを生成

```bash
cd /Users/zettai1st/tokyofamily/TokyoFriends
./generate_xcode.sh
```

または：

```bash
swift package generate-xcodeproj
open TokyoFriends.xcodeproj
```

---

## ✅ ビルド前チェックリスト

### 1. システム要件
- ✅ macOS 14.0+ (Sonoma推奨)
- ✅ Xcode 15.0+
- ✅ iOS 16.0+ SDK
- ✅ Swift 5.9+

### 2. ビルド設定確認

#### Build Settings:
- **iOS Deployment Target**: iOS 16.0
- **Swift Language Version**: Swift 5
- **Enable Previews**: YES

#### Signing & Capabilities:
- Development Teamを設定
- Bundle Identifierを変更（例: `com.yourteam.tokyofriends`）

---

## 🔍 潜在的なエラーと修正

### エラー1: "Cannot find type 'X' in scope"

**原因**: ファイルがターゲットに含まれていない

**修正方法**:
1. Xcodeでファイルを選択
2. File Inspector (⌘⌥1) を開く
3. "Target Membership"で"TokyoFriends"にチェック

### エラー2: "@Observable は使用できません"

**原因**: iOS 16でObservationフレームワークが使用できない

**修正方法**:
- iOS 17+でのみObservationが利用可能
- iOS 16対応の場合、`@ObservableObject`に変更が必要
- 現在の実装はiOS 17+推奨

### エラー3: "Missing required module 'SwiftUI'"

**修正方法**:
```bash
# DerivedDataをクリーン
rm -rf ~/Library/Developer/Xcode/DerivedData/TokyoFriends-*

# Xcodeを再起動
```

### エラー4: "Ambiguous use of 'X'"

**原因**: 名前衝突

**修正箇所**:
- `ExploreViewModel.swift:68` - `error`変数名を`loadError`に変更済み
- `ProfileEditViewModel.swift:23` - `currentUserId`をpublicに変更済み

---

## 🚀 初回ビルド手順

### 1. Clean Build Folder
```
Product → Clean Build Folder (⌘⇧K)
```

### 2. Resolve Package Dependencies
```
File → Packages → Resolve Package Versions
```

### 3. Select Target
- Scheme: `TokyoFriends`
- Destination: `iPhone 15 Pro` (Simulator) または実機

### 4. Build & Run
```
Product → Run (⌘R)
```

---

## 📋 修正済みの問題

### ✅ 修正1: ExploreViewModel.error プロパティ追加
**ファイル**: `Presentation/ViewModels/ExploreViewModel.swift`
**変更**: `var error: Error?` を追加

**理由**: ExploreViewで`viewModel.error`を参照しているため

### ✅ 修正2: ProfileEditViewModel.currentUserId を public に
**ファイル**: `Presentation/ViewModels/ProfileEditViewModel.swift`
**変更**: `private let currentUserId` → `let currentUserId`

**理由**: BlockListViewから`profileViewModel.currentUserId`を参照するため

### ✅ 修正3: CardFilters.isEmpty 定義確認
**ファイル**: `Domain/RepositoryProtocols/CardRepository.swift`
**状態**: 既に定義済み（問題なし）

### ✅ 修正4: Assets.xcassets 作成
**パス**: `TokyoFriends/Resources/Assets.xcassets`
**内容**:
- AppIcon.appiconset/
- AccentColor.colorset/
- Contents.json

---

## 🏗️ プロジェクト構造

```
TokyoFriends/
├── TokyoFriendsApp.swift          # @main エントリーポイント
├── Domain/                         # ビジネスロジック
│   ├── Entities/                  # User, Profile, Match等
│   ├── RepositoryProtocols/       # Repository interfaces
│   └── UseCases/                  # ビジネスロジック
├── Data/                           # データアクセス層
│   ├── Repositories/              # Repository実装
│   ├── Mock/                      # モックデータ
│   └── DI/                        # 依存性注入
├── Presentation/                   # UI層
│   ├── ViewModels/                # MVVM ViewModels
│   ├── Screens/                   # 画面コンポーネント
│   ├── Components/                # 再利用可能UI
│   ├── Navigation/                # ナビゲーション
│   └── DesignSystem/              # デザイントークン
└── Resources/                      # アセット
    └── Assets.xcassets/           # 画像・色
```

---

## 🐛 ビルドエラー発生時の対処

### Step 1: エラーメッセージを確認
- Xcodeの Issue Navigator (⌘4) を開く
- エラーの詳細を確認

### Step 2: Clean & Rebuild
```bash
# ターミナルから
cd /Users/zettai1st/tokyofamily/TokyoFriends
rm -rf .build
rm -rf .swiftpm
swift package clean
swift package resolve
```

### Step 3: Xcode DerivedData削除
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/TokyoFriends-*
```

### Step 4: Xcodeを再起動

---

## 📱 実機でのテスト

### 1. Apple Developer Accountが必要
- 無料アカウントでOK（7日間署名）
- https://developer.apple.com

### 2. Provisioning Profile設定
1. Signing & Capabilities タブを開く
2. "Automatically manage signing"にチェック
3. Teamを選択

### 3. デバイス接続
1. iPhoneをMacに接続
2. "Trust This Computer"を許可
3. Xcodeでデバイスを選択
4. Run (⌘R)

---

## 🔧 トラブルシューティング

### Q: "Unable to boot device" エラー
**A**: Simulatorを再起動
```bash
xcrun simctl shutdown all
xcrun simctl boot "iPhone 15 Pro"
```

### Q: "SwiftUI Preview が動作しない"
**A**: Preview用のビルドをクリーン
```
Editor → Canvas → (Canvas をオフにしてオンに)
```

### Q: "Module 'TokyoFriends' not found"
**A**: ターゲット設定を確認
1. Project Navigator でプロジェクトを選択
2. Targetsで "TokyoFriends" を選択
3. Build Phasesで全てのSwiftファイルが含まれているか確認

---

## 📊 ビルド確認コマンド

### すべてのSwiftファイルを確認
```bash
find TokyoFriends -name "*.swift" | wc -l
# 期待値: 72ファイル
```

### 構文チェック（個別ファイル）
```bash
swiftc -typecheck TokyoFriends/TokyoFriendsApp.swift \
    -sdk $(xcrun --show-sdk-path --sdk iphonesimulator)
```

### Package依存関係の確認
```bash
swift package show-dependencies
```

---

## ✨ ビルド成功後の確認事項

### 起動時チェック
- [ ] Splash画面が表示される
- [ ] Age Gate画面に遷移する
- [ ] ログイン画面が表示される

### オンボーディングチェック
- [ ] 5ステップのオンボーディングが機能する
- [ ] プログレスバーが正しく動作する

### メイン機能チェック
- [ ] ホーム画面のおすすめカードが表示される
- [ ] カードスワイプが動作する
- [ ] フィルタ画面が開く
- [ ] コミュニティ一覧が表示される
- [ ] マッチ一覧が表示される
- [ ] 設定画面が開く

---

## 📝 既知の制限事項

### iOS 16 vs iOS 17
- **@Observable**: iOS 17+のみ
- iOS 16で動作させる場合、`@ObservableObject`への変換が必要

### モックデータ
- 全てのデータはモック（実際のAPI接続なし）
- Repository実装を置き換えることで実API対応可能

### 未実装機能
- 写真アップロード (PHPickerViewController)
- プッシュ通知
- Instagram Deep Link実行
- Firebase Analytics統合

---

## 🎯 次のステップ

ビルドが成功したら：

1. **実機テスト**: iPhone実機でテスト
2. **アクセシビリティ検証**: VoiceOverでテスト
3. **パフォーマンス計測**: Instrumentsで計測
4. **ユニットテスト追加**: XCTestでテスト追加
5. **UIテスト追加**: XCUITestで自動テスト

---

## 📞 サポート

問題が解決しない場合：

1. GitHub Issuesで報告
2. Xcodeコンソールのログを確認
3. Build Log (⌘9) を確認

---

**最終更新**: 2025-10-20
**対象バージョン**: v1.0 (MVP)
**Xcode**: 15.0+
**iOS**: 16.0+
