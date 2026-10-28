<!-- i18n-source: README.md@d9de57463180a0f24deae8e38d6a6e79f81f6be3 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

MobileLogger は、iOS、macOS、tvOS、watchOS、visionOS アプリで構造化ログを記録し、何かが書き込まれる前に機密情報を隠す Swift パッケージです。すべてのメッセージとすべての metadata の値は、共有された文書化済みのマスキング仕様に基づくマスカーを通るため、unified logging、デバイス上のストア、エクスポートしたファイルのいずれにも同じ安全なテキストが残ります。ログがデバイスの外に出るアプリチームを想定しています。たとえば、バグレポートに添付される場合、サポートから送られる場合、sysdiagnose から読み取られる場合です。`os.Logger` に書き込み、決められた上限の範囲でログをメモリまたはディスクに保持し、`ShareLink` 向けにエクスポートし、swift-log を使うパッケージのログもマスクします。

## 主な特長

- **すべての経路でマスキング** — メッセージ、metadata のキーと値、URL、HTTP ボディは、マスキング仕様のリファレンス実装である [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) の `SensitiveDataRedactor` を通ります。対象は、秘密情報の名前、カード番号（Luhn）、IBAN（mod-97）、メールアドレス、JSON Web Token、bearer トークンと長いトークンです。
- **仕様に照らして検証** — 仕様が定める必須テストセットと、7,866 件の敵対的な入力からなるコーパスを、ロガー自身のエントリポイントから実行します。出力はすべての入力でリファレンスのマスカーの出力と一致しなければならず、エクスポートは隠した内容を加えてはなりません。
- **Fail-closed の上限** — 大きすぎるメッセージ、64 階層を超えてネストした、256 KiB を超える、または URL とボディの合計が 256 KiB を超える metadata、長すぎる URL は、中途半端に読まれずに全体が隠されます。NaN、無限大、`Int.min` で trap が起きることはありません。
- **上限のあるストア** — `MemoryLogStore` は件数とバイト数の予算の範囲で最新のレコードを保持し、`FileLogStore` は決まった数の JSON Lines ファイルをローテーションします。どちらも、増え続けるのではなく、破棄したレコードを数えます。
- **共有できる形でエクスポート** — `LogArchive` はレベルと日付で絞り込んだ JSON Lines またはテキストを書き出し、`ShareLink` 向けに `Transferable` に準拠しています。
- **swift-log ブリッジ** — `RedactingLogHandler` は、swift-log を使うすべてのパッケージのログを同じマスカーとストアに通します。

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/MobileLogger.git
```

ウィンドウ右上の検索欄に貼り付けます。**Dependency Rule** は `2.0.0` からの **Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで、**MobileLogger** の横でアプリの target を選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import MobileLogger
```

この行を、ログを記録する Swift ファイルの先頭に置きます。

**3. 使ってみる**

機能ごとにロガーを 1 つ作り、データを metadata に入れたメッセージを記録します。

```swift
import MobileLogger

extension MobileLogger {
    /// One logger per feature; make it once and use it anywhere.
    static let checkout = MobileLogger(category: "Checkout")
}

func quickStart() {
    MobileLogger.checkout.info("Payment sent", metadata: [
        "status": 200,
        "note": "paid with 4242 4242 4242 4242",
        "email": "alice@example.com",
        "password": "hunter2",
    ])
    // Xcode's console and Console.app show:
    // Payment sent {"email":"a•••@example.com","note":"paid with •••• 4242","password":"[redacted]","status":200}
}
```

`quickStart()` をボタンまたは `.task` から呼び出し、アプリを実行して Xcode のコンソールを確認します。

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/MobileLogger.git
```

または `Package.swift` の `dependencies` に追加します。

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/MobileLogger.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "MobileLogger", package: "MobileLogger"),
        // Only if the app or its packages log with swift-log:
        .product(name: "MobileLoggerSwiftLog", package: "MobileLogger"),
    ])
]
```

このパッケージは [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)（マスカー）と [swift-log](https://github.com/apple/swift-log)（`MobileLoggerSwiftLog` プロダクトだけが使用）に依存します。

## 使い方

以下のサンプルは、[`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) と [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift) からコピーしたものです。この 2 つのファイルはサンプルアプリとテストがコンパイルしており、テストはコメント内のすべての出力を検証します。

### メッセージと metadata を書き込む

メッセージは、切り取り位置が 1 つだけの自由テキストです。許可されていない最初のキー、または最初の秘密情報の名前が、その後ろをすべて隠します。メッセージは変化しない文にして、値は metadata に入れてください。metadata ではキーごとに個別に判定されます。

```swift
func messagesAndMetadata(log: MobileLogger) {
    // A message is free text: the first key that is not allowed hides the rest of it.
    log.info("Signed in user=alice")                  // Signed in user=[redacted]
    log.info("GET /orders status=200 duration_ms=41") // kept: status, duration_ms are allowed

    // Metadata keeps values under keys that name no secret.
    log.info("Signed in", metadata: ["user": "alice", "attempt": 2])
    // Signed in {"attempt":2,"user":"alice"}
}
```

### URL と HTTP ボディを記録する

`.url` は、ユーザー名、パスワード、フラグメントを取り除き、パス内の識別子を `:id` に置き換え、クエリの値を隠します。`.body` は、JSON、フォーム、multipart、プレーンテキストのボディを content type に従って読み取り、それ以外のボディは省略します。

```swift
func urlsAndBodies(log: MobileLogger) {
    let url = URL(string: "https://bob:pw@api.example.com/users/12345678/orders?page=2#top")!
    let body = Data(#"{"id":7,"access_token":"eyJhbGciOiJIUzI1NiJ9.e30.x","items":3}"#.utf8)
    log.info("Request finished", metadata: [
        "url": .url(url),
        "status": 200,
        "response": .body(body, contentType: "application/json"),
    ])
    // Request finished {"response":"{\"id\":7,\"access_token\":\"[redacted]\",\"items\":3}",
    //   "status":200,"url":"https://api.example.com/users/:id/orders?page=[redacted]"}
}
```

### ログを保持してエクスポートする

```swift
func storesAndExport() async throws -> LogArchive {
    let memory = MemoryLogStore(capacity: 2_000)
    let disk = FileLogStore() // Library/Caches/MobileLogger, 4 files of 1 MiB
    let log = MobileLogger(category: "Sync", sinks: [OSLogSink(), memory, disk])

    log.error("Upload failed", metadata: ["error": .error(URLError(.timedOut)), "attempt": 3])

    // Everything a store holds was redacted when it was logged.
    return try await LogArchive.make(from: disk, format: .text, minimumLevel: .warning)
}
```

アーカイブは `ShareLink(item: archive, preview: SharePreview(archive.fileName))` に渡すか、`archive.write(to:)` でフォルダに書き出します。

### swift-log をマスカー経由にする

```swift
/// Sends the logs of every package that uses swift-log through the redactor. Call it once,
/// early in the app's life: swift-log accepts one bootstrap per process.
func bootstrapSwiftLog(store: MemoryLogStore) {
    let base = MobileLogger(sinks: [OSLogSink(), store])
    LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }

    let logger = Logger(label: "com.example.sync")
    logger.info("Sync finished", metadata: ["token": "abc123", "items": "42"])
    // Sync finished {"items":"42","token":"[redacted]"}
}
```

### 必要な箇所だけ許可を広げる

デフォルトでは最も多くを隠します。`RedactionPolicy` で通す範囲を広げられますが、秘密情報の名前のルールや検出器をオフにすることはできません。

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## ほかのものを選ぶ場合

| 必要なもの                                        | 使うもの                                                                                                                                |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 公開するライブラリ用のログ API                    | [swift-log](https://github.com/apple/swift-log)。アプリ側で `RedactingLogHandler` を経由させます                                        |
| コンソール UI を備えたネットワークインスペクタ    | [Pulse](https://github.com/kean/Pulse)。マスクするのは、指定したヘッダー、クエリ項目、JSON フィールドだけで、メッセージはマスクしません |
| unified logging の外に出ないログ                  | 各補間に `privacy:` を付けた `os.Logger`                                                                                                |
| すでにそれを使っている Objective-C のコードベース | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                                   |
| Linux サーバーでのログ                            | サーバー用ハンドラを使う swift-log。MobileLogger は OSLog を使うため、Apple プラットフォームでのみ動作します                            |

それぞれのケースと組み合わせ方は、[Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) の記事で説明しています。

## デモ

| ライト                                                                                    | ダーク                                                                                   |
| ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| ![マスク済みのレコードを表示する LogExplorer、ライト](docs/images/log-explorer-light.png) | ![マスク済みのレコードを表示する LogExplorer、ダーク](docs/images/log-explorer-dark.png) |

サンプルアプリ [LogExplorer](Examples/LogExplorer) は、アプリがうっかりやりがちな形で機密情報を含む 4 つのイベントを記録し、各 sink が受け取った内容を一覧表示します。Xcode で `Examples/LogExplorer/LogExplorer.xcodeproj` を開き、iPhone シミュレータまたは **My Mac** を選んで **Run** を押し、**+** ボタンでイベントを記録します。共有ボタンでエクスポートできます。スクリーンショットは [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) がアプリから取得したものです。詳細は [Examples/README.md](Examples/README.md) にあります。

## ドキュメント

API リファレンスと解説記事：

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — すべての公開型を網羅し、DocC で生成して、ドキュメント用の workflow が公開します。
- このパッケージが従うマスキング仕様は、[iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) で実装され、ドキュメント化されています。

## ガイド

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — パッケージの追加から、マスクされ、保持され、エクスポートされるログまで。
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — メッセージ、metadata、URL、ボディがどのように読み取られるか、そして何が検出されないか。
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — ストアの上限、アーカイブ形式、`ShareLink`、カスタム sink。
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — `os.Logger`、swift-log、Pulse、CocoaLumberjack のどれが適しているか。

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| ツールチェーン | Swift 6.2 · Xcode 26+ |

CI は、GitHub の `macos-26` ランナーイメージに入っているデフォルトの Xcode でビルドします。パッケージ自体は Xcode 27 で開発しています。

## アーキテクチャ

```text
log.info(message, metadata)
  └─ MobileLogger ── level check, then RecordRedactor
       ├─ message   → SensitiveDataRedactor.redact(_:)          free text, one cut point
       ├─ metadata  → one JSON object → redact(body:"application/json")
       │    ├─ .url  → redact(url:)    put back only where its key keeps it
       │    └─ .body → redact(body:contentType:)
       └─ LogRecord (redacted) → every LogSink
            ├─ OSLogSink        os.Logger, public
            ├─ MemoryLogStore   count + byte budget
            └─ FileLogStore     rotating JSON Lines → LogArchive → ShareLink
```

- `Sources/MobileLogger` には、ロガー、レコード型、sink（`Sinks/`）、エクスポート（`Export/`）が入っています。`Sources/MobileLoggerSwiftLog` には swift-log のハンドラが入っています。swift-log を使わないアプリがリンクしないよう、別のプロダクトになっています。
- マスキングは、どの sink が呼ばれるよりも前に、ログを記録したスレッドで 1 回だけ行われます。sink が目にするのは `LogRecord` の値だけなので、新しい sink がマスカーの隠した内容を漏らすことはありません。
- URL とボディは、まずそれぞれのパーサーでマスクされます。次に metadata の JSON を、その位置にマスク後のテキストを置いて読みます。これにより URL やボディも、ほかの文字列と同じように隣接する値を隠します。さらにもう一度、その位置に代わりの単語を置いて読みます。テキストが隣接する値に対して秘密を名指す場合は秘密を名指す単語、そうでない場合は中立の目印です。その単語が変更されずに戻ってきた場合（そのキーと隣接する値が何も隠していない場合）にだけ、URL やボディのテキストが残ります。それ以外の場所では、値は隠されたままです。そのため、最初のボディが `password` と読める 2 つのボディの組は、2 つの文字列の組と同じように 2 番目を隠します。URL やボディは渡されたままの形でも読まれるため、パーサーが書き換える名前（`<unparsed URL>` と書かれる相対 URL `password`）も、隣の値を隠します。
- すべての上限は fail-closed です。上限を超えると、ロガーはより多くを隠すか破棄し、少なくなることは決してありません。また、破棄した件数も数えます。
- テストは Swift Testing を使い、macOS と iPhone シミュレータで実行されます。対象は、仕様の必須セットとコーパス、metadata のパイプライン、ストア、エクスポート、swift-log ブリッジ、README のサンプル、そして `OSLogStore` を使った unified logging の往復です。

テストをローカルで実行するには次のようにします。

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## ロードマップ

- サンプルアプリのリストをもとにした、すぐ使える SwiftUI のログビューア。
- `FileLogStore` に、サイズと件数の上限に加えて、時間に基づく保持期間を追加。
- パッケージの Swift Package Index への登録。`.spi.yml` はすでにリポジトリにあります。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
