<!-- i18n-source: README.md@448e50b8cf38056bf1786c19c1b3c09c557e7ac2 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

MobileLogger 是一个 Swift 包，用于在 iOS、macOS、tvOS、watchOS 和 visionOS 应用中进行结构化日志记录，并在任何内容写入之前隐藏敏感信息。每条消息和每个 metadata 值都会经过一份统一的书面脱敏规范所对应的脱敏器，因此 unified logging、设备上的存储以及导出的文件中保存的都是同样安全的文本。它面向日志会离开设备的应用团队：附在错误报告里、由客服发送，或从 sysdiagnose 中读取。它会写入 `os.Logger`，在固定上限内把日志保存在内存或磁盘上，导出后可用于 `ShareLink`，并且也会对使用 swift-log 的软件包的日志进行脱敏。

## 亮点

- **每条路径都经过脱敏** — 消息、metadata 的键和值、URL 以及 HTTP body 都会经过 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) 中的 `SensitiveDataRedactor`（脱敏规范的参考实现）：密钥名称、银行卡号（Luhn）、IBAN（mod-97）、电子邮件地址、JSON Web Token、bearer token 和长 token。
- **按规范校验** — 规范要求的测试集以及包含 7,866 个对抗性输入的语料库，会通过日志器自己的入口运行；对每个输入，输出都必须与参考脱敏器的输出一致，并且导出内容不得添加被隐藏的信息。
- **Fail-closed 上限** — 过大的消息、嵌套超过 64 层或大于 256 KiB 的 metadata，以及过长的 URL，都会被整体隐藏，而不是只读一半；NaN、无穷大和 `Int.min` 永远不会触发 trap。
- **有界存储** — `MemoryLogStore` 在条数和字节预算内保留最新的记录，`FileLogStore` 轮转固定数量的 JSON Lines 文件，二者都会统计被丢弃的记录，而不是无限增长。
- **导出即可分享** — `LogArchive` 可按级别和日期过滤并写出 JSON Lines 或文本，并遵循 `Transferable`，可用于 `ShareLink`。
- **swift-log 桥接** — `RedactingLogHandler` 会让所有使用 swift-log 的软件包的日志经过同一个脱敏器和同样的存储。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/MobileLogger.git
```

把它粘贴到窗口右上角的搜索框中。将 **Dependency Rule** 保持为 **Up to Next Major Version**，起始版本为 `2.0.0`，然后点击 **Add Package**。在接下来的窗口中，在 **MobileLogger** 旁边选择你的应用 target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import MobileLogger
```

把这一行放在你记录日志的 Swift 文件顶部。

**3. 开始使用**

为每个功能创建一个日志器，并记录一条数据放在 metadata 中的消息：

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

在按钮或 `.task` 中调用 `quickStart()`，运行应用，然后查看 Xcode 的控制台。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/MobileLogger.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

该包依赖 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)（脱敏器）和 [swift-log](https://github.com/apple/swift-log)（仅由 `MobileLoggerSwiftLog` 产品使用）。

## 使用方法

下面的示例复制自 [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) 和 [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift)，示例应用和测试都会编译这两个文件；测试会检查注释中的每一条输出。

### 写入消息和 metadata

消息是只有一个截断点的自由文本：第一个不被允许的键或第一个密钥名称，会隐藏其后的全部内容。请让消息保持为固定的句子，并把值放进 metadata，其中每个键都会被单独判断。

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

### 记录 URL 和 HTTP body

`.url` 会去掉用户名、密码和 fragment，把路径中的标识符替换为 `:id`，并隐藏查询参数的值。`.body` 会按 content type 读取 JSON、表单、multipart 和纯文本 body，并省略其他任何类型的 body。

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

### 保存日志并导出

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

把归档交给 `ShareLink(item: archive, preview: SharePreview(archive.fileName))`，或用 `archive.write(to:)` 写入某个文件夹。

### 让 swift-log 经过脱敏器

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

### 在需要的地方放宽限制

默认设置隐藏得最多。`RedactionPolicy` 可以放行更多内容，但无法关闭密钥名称规则或各类检测器。

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## 何时选择其他方案

| 你需要                            | 使用                                                                                                |
| --------------------------------- | --------------------------------------------------------------------------------------------------- |
| 为你发布的库提供日志 API          | [swift-log](https://github.com/apple/swift-log)；应用再通过 `RedactingLogHandler` 接入              |
| 带控制台界面的网络检查器          | [Pulse](https://github.com/kean/Pulse)；它只会对你指定的 header、查询项和 JSON 字段脱敏，不处理消息 |
| 永远不离开 unified logging 的日志 | 在每个插值上使用 `privacy:` 的 `os.Logger`                                                          |
| 已经在使用它的 Objective-C 代码库 | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                               |
| Linux 服务器上的日志              | 搭配服务器端 handler 的 swift-log；MobileLogger 使用 OSLog，只能在 Apple 平台上运行                 |

[Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) 一文逐一说明了各种情况以及如何组合使用。

## 演示

| 浅色                                                                      | 深色                                                                     |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| ![LogExplorer 显示已脱敏的记录，浅色](docs/images/log-explorer-light.png) | ![LogExplorer 显示已脱敏的记录，深色](docs/images/log-explorer-dark.png) |

示例应用 [LogExplorer](Examples/LogExplorer) 会记录四个带有敏感信息的事件（应用常常会不小心这样做），并列出它的各个 sink 收到的内容。在 Xcode 中打开 `Examples/LogExplorer/LogExplorer.xcodeproj`，选择一个 iPhone 模拟器或 **My Mac**，点击 **Run**，然后用 **+** 按钮记录事件；分享按钮可将它们导出。截图由 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 从应用中截取；详情见 [Examples/README.md](Examples/README.md)。

## 文档

API 参考文档与文章：

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — 每一个公开类型，由 DocC 构建，并由文档 workflow 发布。
- 该包所遵循的脱敏规范，在 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) 中实现并有文档说明。

## 指南

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — 从添加软件包，到日志被脱敏、保存和导出。
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — 消息、metadata、URL 和 body 是如何被读取的，以及哪些内容检测不到。
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — 存储上限、归档格式、`ShareLink` 和自定义 sink。
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — 何时 `os.Logger`、swift-log、Pulse 或 CocoaLumberjack 更合适。

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| 工具链 | Swift 6.2 · Xcode 26+ |

CI 使用 GitHub `macos-26` runner 镜像自带的默认 Xcode 进行构建。该包使用 Xcode 27 开发。

## 架构

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

- `Sources/MobileLogger` 包含日志器、记录类型、各个 sink（`Sinks/`）和导出功能（`Export/`）。`Sources/MobileLoggerSwiftLog` 包含 swift-log handler，它是一个独立的产品，因此不使用 swift-log 的应用不会链接它。
- 脱敏在调用任何 sink 之前、在记录日志的线程上只进行一次。sink 看到的始终只是 `LogRecord` 值，所以新增的 sink 不可能泄露脱敏器已隐藏的内容。
- URL 和 body 先由各自的解析器脱敏。随后读取 metadata 的 JSON 时，先把脱敏后的文本放在它们的位置上，这样 URL 或 body 会像其他字符串一样隐藏相邻的值；再把一个标记词放在它们的位置上读一次：只有当这个词原样返回时（它的键及其相邻内容都没有隐藏任何东西），才保留 URL 或 body 的文本；在其他任何地方，该值都保持隐藏。
- 每一项上限都是 fail-closed：一旦超出，日志器会隐藏或丢弃更多内容，绝不会更少，并且会统计被丢弃的记录。
- 测试使用 Swift Testing，在 macOS 和 iPhone 模拟器上运行：规范要求的测试集和语料库、metadata 处理流程、存储、导出、swift-log 桥接、README 示例，以及通过 `OSLogStore` 经 unified logging 的一次往返。

在本地运行测试：

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 路线图

- 基于示例应用的列表构建一个现成的 SwiftUI 日志查看器。
- 除大小和数量上限之外，为 `FileLogStore` 增加基于时间的保留策略。
- 将该包加入 Swift Package Index；`.spi.yml` 已经在仓库中。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
