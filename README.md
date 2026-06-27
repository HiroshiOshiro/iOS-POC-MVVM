# iOS-POC-MVVM

Objective-C / UIKit で書いた MVVM 構成の iOS POC アプリ。

## 機能

### Dog タブ
- **犬種一覧画面** — [dog.ceo API](https://dog.ceo/api/breeds/list/all) から犬種一覧を取得して表示。各行にお気に入り（♡）ボタン。
- **犬種詳細画面** — 犬種名・サブ犬種・犬の画像（API から取得）をグリッド表示。ナビゲーションバーにお気に入りボタン。

### お気に入りタブ
- **お気に入り一覧画面** — 登録済みの犬種を表示（スワイプまたは ♡ で削除可）。
- **お気に入り詳細画面** — 犬種詳細画面と同一の画面を再利用。

### Setting タブ
- メールアドレス / パスワードでのログイン UI。
- 認証は**モック**（`AuthService`）。本来の API 送信処理（`NSURLSession` POST）はコメントで形を残しつつ、ローカルで結果を返す。パスワードは 4 文字以上で成功。
- ログイン成功でユーザー情報（名前・ID・メール・トークン）を表示。

## アーキテクチャ（MVVM）

```
Sources/
├── App/          AppDelegate / SceneDelegate（3 タブ構成）/ Info.plist
├── Models/       Breed, User
├── Services/     DogAPIService（通信）, AuthService（モック認証）,
│                 FavoritesStore（NSUserDefaults 永続化）
├── Common/       ImageLoader（画像の非同期取得 + メモリキャッシュ）
└── Features/
    ├── Dog/        BreedList / BreedDetail（ViewModel + ViewController + Cell）
    ├── Favorites/  FavoritesList（ViewModel + ViewController）
    └── Settings/   Settings（ViewModel + ViewController）
```

- **View（UIViewController）** は ViewModel を保持し、`onStateChange` ブロックで状態変化を購読して UI を更新する。
- **ViewModel** が状態（一覧・ローディング・エラー）とロジックを持ち、Service 層を呼ぶ。UIKit に依存しない。
- **Service** が通信・永続化を担当。お気に入りの変更は `FavoritesStoreDidChangeNotification` で各画面に伝播する。

## ビルド方法

`.xcodeproj` は [XcodeGen](https://github.com/yonyz/XcodeGen) で生成する（`project.yml` が定義）。

```sh
brew install xcodegen          # 未インストールの場合
cd iOS-POC-MVVM
xcodegen generate              # iOS-POC-MVVM.xcodeproj を生成
open iOS-POC-MVVM.xcodeproj    # Xcode で開いて Run
```

コマンドラインからシミュレータ向けにビルドする場合:

```sh
xcodebuild -project iOS-POC-MVVM.xcodeproj -scheme iOS-POC-MVVM \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

- Deployment target: iOS 15.0
- Bundle ID: `com.poc.iOS-POC-MVVM`
- Storyboard 不使用（全画面コードで構築）
