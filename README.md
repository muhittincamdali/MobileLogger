<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

MobileLogger is a Swift package for structured logging in iOS, macOS, tvOS, watchOS and visionOS
apps that hides secrets before anything is written. Every message and every metadata value goes
through the redactor of a shared, written redaction spec, so unified logging, the on-device
stores and an exported file all hold the same safe text. It is for app teams whose logs leave the
device: attached to bug reports, sent by support, or read from a sysdiagnose. It writes to
`os.Logger`, keeps logs in memory or on disk within fixed limits, exports them for `ShareLink`,
and redacts the logs of packages that use swift-log too.

## Highlights

- **Redaction on every path** — messages, metadata keys and values, URLs and HTTP bodies go
  through `SensitiveDataRedactor` from
  [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools), the reference
  implementation of the redaction spec: secret names, card numbers (Luhn), IBANs (mod-97),
  email addresses, JSON Web Tokens, bearer and long tokens.
- **Checked against the spec** — the spec's required test set and its corpus of 7,866
  adversarial inputs run through the logger's own entry points; the output must equal the
  reference redactor's for every input, and the export must not add what it hides.
- **Fail-closed limits** — oversized messages, metadata nested more than 64 levels, larger
  than 256 KiB or holding more than 256 KiB of URLs and bodies, and over-long URLs are hidden
  whole instead of half read; NaN, infinity and `Int.min` never trap.
- **Bounded stores** — `MemoryLogStore` keeps the newest records within a count and a byte
  budget, `FileLogStore` rotates a fixed number of JSON Lines files, and both count what they
  drop instead of growing.
- **Export ready to share** — `LogArchive` writes JSON Lines or text, filtered by level and date,
  and conforms to `Transferable` for `ShareLink`.
- **swift-log bridge** — `RedactingLogHandler` sends the logs of every package that uses
  swift-log through the same redactor and stores.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Paste it into the search field at the top right of the window. Leave **Dependency Rule** at
**Up to Next Major Version** from `2.0.0`, then click **Add Package**. In the next window,
choose your app target next to **MobileLogger** and click **Add Package** again.

**2. Import the module**

```swift
import MobileLogger
```

Put this line at the top of the Swift file where you log.

**3. Use it**

Make one logger per feature and log a message whose data is in the metadata:

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

Call `quickStart()` from a button or `.task`, run the app and look at Xcode's console.

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Or add it to the `dependencies` in your `Package.swift`:

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

The package depends on [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)
(the redactor) and [swift-log](https://github.com/apple/swift-log) (used only by the
`MobileLoggerSwiftLog` product).

## Usage

The samples below are copied from
[`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) and
[`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift),
which the example app and the tests compile; the tests check every output in the comments.

### Write messages and metadata

A message is free text with a single cut point: the first key that is not allowed, or the first
secret name, hides the rest of it. Keep the message a constant sentence and put values in the
metadata, where each key is judged on its own.

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

### Log URLs and HTTP bodies

`.url` drops the user name, password and fragment, replaces identifiers in the path with `:id`
and hides query values. `.body` reads JSON, form, multipart and plain-text bodies by their
content type and omits any other body.

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

### Keep logs and export them

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

Hand the archive to `ShareLink(item: archive, preview: SharePreview(archive.fileName))`, or write
it to a folder with `archive.write(to:)`.

### Route swift-log through the redactor

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

### Allow more where you need it

The defaults hide the most. A `RedactionPolicy` can let more through, but it cannot switch the
secret-name rule or the detectors off.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## When to use something else

| You need                                      | Use                                                                                                                 |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| A logging API for a library you publish       | [swift-log](https://github.com/apple/swift-log); apps then route it through `RedactingLogHandler`                   |
| A network inspector with a console UI         | [Pulse](https://github.com/kean/Pulse); it redacts only headers, query items and JSON fields you name, not messages |
| Logs that never leave unified logging         | `os.Logger` with `privacy:` on each interpolation                                                                   |
| An Objective-C code base that already uses it | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                               |
| Logging on Linux servers                      | swift-log with a server handler; MobileLogger uses OSLog and runs on Apple platforms only                           |

The [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger)
article explains each case and how to combine them.

## Demo

| Light                                                                              | Dark                                                                             |
| ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| ![LogExplorer showing redacted records, light](docs/images/log-explorer-light.png) | ![LogExplorer showing redacted records, dark](docs/images/log-explorer-dark.png) |

The [LogExplorer](Examples/LogExplorer) example app logs four events that carry secrets the way
apps often do by mistake and lists what its sinks received. Open
`Examples/LogExplorer/LogExplorer.xcodeproj` in Xcode, choose an iPhone simulator or **My Mac**,
press **Run**, and log events with the **+** button; the share button exports them. The
screenshots are captured from the app by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh);
[Examples/README.md](Examples/README.md) has the details.

## Documentation

Reference documentation and articles:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/)
  — every public type, built with DocC and published by the documentation workflow.
- The redaction spec the package follows is implemented and documented in
  [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools).

## Guides

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted)
  — from adding the package to logs that are redacted, kept and exported.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules)
  — how messages, metadata, URLs and bodies are read, and what is not found.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs)
  — store limits, archive formats, `ShareLink` and custom sinks.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger)
  — when `os.Logger`, swift-log, Pulse or CocoaLumberjack fits better.

## Requirements

| Platform  | Minimum version       |
| --------- | --------------------- |
| iOS       | 18                    |
| macOS     | 15                    |
| tvOS      | 18                    |
| watchOS   | 11                    |
| visionOS  | 2                     |
| Toolchain | Swift 6.2 · Xcode 26+ |

CI builds with the default Xcode of GitHub's `macos-26` runner image. The package is developed
with Xcode 27.

## Architecture

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

- `Sources/MobileLogger` holds the logger, the record types, the sinks (`Sinks/`) and the export
  (`Export/`). `Sources/MobileLoggerSwiftLog` holds the swift-log handler, a separate product so
  apps without swift-log do not link it.
- Redaction happens once, on the thread that logs, before any sink is called. Sinks only ever see
  `LogRecord` values, so a new sink cannot leak what the redactor hid.
- URLs and bodies are redacted by their own parsers first. The metadata JSON is then read with
  that text in their place, so a URL or body hides its neighbours like any other string, and
  once more with a stand-in word in their place: a word that names a secret where the text
  names one to its neighbours, a neutral marker elsewhere. Only where that word comes back
  unchanged (its key and its neighbours hide nothing) is the URL or body text kept; anywhere
  else the value stays hidden. A pair of bodies whose first reads `password` therefore hides the
  second, as a pair of strings would. A URL or body is also read as it was given, so a name its
  parser rewrites (the relative URL `password`, written as `<unparsed URL>`) still hides what is
  beside it.
- Every limit fails closed: past it, the logger hides or drops more, never less, and counts what
  it drops.
- Tests use Swift Testing and run on macOS and an iPhone simulator: the spec's required set and
  corpus, the metadata pipeline, the stores, the export, the swift-log bridge, the README
  samples, and a round trip through unified logging with `OSLogStore`.

Run the tests locally:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roadmap

- A ready-made SwiftUI log viewer, built from the example app's list.
- Time-based retention for `FileLogStore`, next to the size and count limits.
- Adding the package to the Swift Package Index; `.spi.yml` is already in the repository.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
