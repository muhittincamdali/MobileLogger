<!-- i18n-source: README.md@8c833a0657592da40b88fd09c24a13d1f4fc5d7c status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

MobileLogger는 iOS, macOS, tvOS, watchOS, visionOS 앱에서 구조화된 로깅을 제공하며, 무언가가 기록되기 전에 비밀 정보를 가리는 Swift 패키지입니다. 모든 메시지와 모든 metadata 값은 문서화된 공통 마스킹 사양의 마스커를 거치므로, unified logging, 기기 내 저장소, 내보낸 파일에 모두 동일하게 안전한 텍스트가 남습니다. 로그가 기기 밖으로 나가는 앱 팀을 위한 것으로, 버그 리포트에 첨부되거나, 지원팀이 보내거나, sysdiagnose에서 읽는 경우가 해당합니다. `os.Logger`에 기록하고, 정해진 한도 안에서 로그를 메모리나 디스크에 보관하며, `ShareLink`용으로 내보내고, swift-log를 사용하는 패키지의 로그도 마스킹합니다.

## 주요 기능

- **모든 경로에서 마스킹** — 메시지, metadata 키와 값, URL, HTTP 본문은 마스킹 사양의 참조 구현인 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)의 `SensitiveDataRedactor`를 거칩니다. 대상은 비밀 이름, 카드 번호(Luhn), IBAN(mod-97), 이메일 주소, JSON Web Token, bearer 토큰과 긴 토큰입니다.
- **사양에 맞춰 검증** — 사양이 요구하는 테스트 세트와 7,866개의 적대적 입력 코퍼스를 로거 자체의 진입점으로 실행합니다. 모든 입력에서 출력이 참조 마스커의 출력과 같아야 하며, 내보내기가 숨긴 내용을 추가해서는 안 됩니다.
- **Fail-closed 한도** — 지나치게 큰 메시지, 64단계를 넘게 중첩되었거나, 256 KiB보다 크거나, URL과 본문이 합쳐서 256 KiB를 넘는 metadata, 지나치게 긴 URL은 절반만 읽는 대신 통째로 숨깁니다. NaN, 무한대, `Int.min`은 trap을 일으키지 않습니다.
- **한도가 있는 저장소** — `MemoryLogStore`는 개수와 바이트 예산 안에서 최신 레코드를 보관하고, `FileLogStore`는 정해진 개수의 JSON Lines 파일을 순환(rotate)하며, 둘 다 계속 커지는 대신 버린 레코드의 수를 셉니다.
- **바로 공유할 수 있는 내보내기** — `LogArchive`는 레벨과 날짜로 필터링한 JSON Lines 또는 텍스트를 쓰며, `ShareLink`용으로 `Transferable`을 따릅니다.
- **swift-log 브리지** — `RedactingLogHandler`는 swift-log를 사용하는 모든 패키지의 로그를 같은 마스커와 저장소로 보냅니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/MobileLogger.git
```

창 오른쪽 위의 검색란에 붙여 넣으세요. **Dependency Rule**은 `2.0.0`부터의 **Up to Next Major Version**으로 두고 **Add Package**를 클릭하세요. 다음 창에서 **MobileLogger** 옆에 앱 target을 선택하고 **Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import MobileLogger
```

이 줄을 로그를 남기는 Swift 파일의 맨 위에 넣으세요.

**3. 사용하기**

기능마다 로거를 하나씩 만들고, 데이터를 metadata에 담아 메시지를 기록하세요.

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

버튼이나 `.task`에서 `quickStart()`를 호출하고, 앱을 실행한 다음 Xcode의 콘솔을 확인하세요.

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/MobileLogger.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

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

이 패키지는 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)(마스커)와 [swift-log](https://github.com/apple/swift-log)(`MobileLoggerSwiftLog` 제품에서만 사용)에 의존합니다.

## 사용법

아래 예제는 [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift)와 [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift)에서 복사한 것입니다. 예제 앱과 테스트가 이 파일들을 컴파일하며, 테스트는 주석에 적힌 모든 출력을 확인합니다.

### 메시지와 metadata 기록하기

메시지는 끊는 지점이 하나뿐인 자유 텍스트입니다. 허용되지 않는 첫 번째 키나 첫 번째 비밀 이름이 그 뒤의 나머지를 숨깁니다. 메시지는 변하지 않는 문장으로 유지하고, 값은 metadata에 넣으세요. metadata에서는 각 키가 개별적으로 판단됩니다.

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

### URL과 HTTP 본문 기록하기

`.url`은 사용자 이름, 비밀번호, fragment를 제거하고, 경로의 식별자를 `:id`로 바꾸며, 쿼리 값을 숨깁니다. `.body`는 JSON, 폼, multipart, 일반 텍스트 본문을 content type에 따라 읽고, 그 밖의 본문은 생략합니다.

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

### 로그 보관하고 내보내기

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

아카이브를 `ShareLink(item: archive, preview: SharePreview(archive.fileName))`에 전달하거나, `archive.write(to:)`로 폴더에 쓰세요.

### swift-log를 마스커로 연결하기

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

### 필요한 곳에서 더 많이 허용하기

기본값은 가장 많이 숨깁니다. `RedactionPolicy`로 더 많은 내용을 통과시킬 수 있지만, 비밀 이름 규칙이나 탐지기를 끌 수는 없습니다.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## 다른 도구를 써야 할 때

| 필요한 것                                    | 사용할 것                                                                                                           |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 배포하는 라이브러리를 위한 로깅 API          | [swift-log](https://github.com/apple/swift-log). 앱에서는 이를 `RedactingLogHandler`로 연결합니다                   |
| 콘솔 UI가 있는 네트워크 인스펙터             | [Pulse](https://github.com/kean/Pulse). 지정한 헤더, 쿼리 항목, JSON 필드만 마스킹하며 메시지는 마스킹하지 않습니다 |
| unified logging 밖으로 나가지 않는 로그      | 각 보간(interpolation)에 `privacy:`를 붙인 `os.Logger`                                                              |
| 이미 그것을 쓰고 있는 Objective-C 코드베이스 | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                               |
| Linux 서버에서의 로깅                        | 서버용 핸들러를 쓰는 swift-log. MobileLogger는 OSLog를 사용하므로 Apple 플랫폼에서만 동작합니다                     |

각 경우와 함께 사용하는 방법은 [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) 문서에서 설명합니다.

## 데모

| 라이트                                                                                 | 다크                                                                                |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| ![마스킹된 레코드를 보여 주는 LogExplorer, 라이트](docs/images/log-explorer-light.png) | ![마스킹된 레코드를 보여 주는 LogExplorer, 다크](docs/images/log-explorer-dark.png) |

예제 앱 [LogExplorer](Examples/LogExplorer)는 앱들이 흔히 실수로 하듯 비밀 정보가 담긴 이벤트 네 개를 기록하고, 각 sink가 받은 내용을 보여 줍니다. Xcode에서 `Examples/LogExplorer/LogExplorer.xcodeproj`를 열고 iPhone 시뮬레이터나 **My Mac**을 선택한 뒤 **Run**을 누르고, **+** 버튼으로 이벤트를 기록하세요. 공유 버튼으로 내보낼 수 있습니다. 스크린샷은 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)가 앱에서 캡처한 것이며, 자세한 내용은 [Examples/README.md](Examples/README.md)에 있습니다.

## 문서

API 레퍼런스와 문서:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — 모든 public 타입을 다루며, DocC로 빌드하고 문서 workflow로 게시합니다.
- 이 패키지가 따르는 마스킹 사양은 [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools)에 구현되고 문서화되어 있습니다.

## 가이드

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — 패키지를 추가하는 것부터 마스킹, 보관, 내보내기까지의 과정.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — 메시지, metadata, URL, 본문을 어떻게 읽는지, 그리고 무엇이 탐지되지 않는지.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — 저장소 한도, 아카이브 형식, `ShareLink`, 커스텀 sink.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — `os.Logger`, swift-log, Pulse, CocoaLumberjack 중 무엇이 더 맞는지.

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| 툴체인 | Swift 6.2 · Xcode 26+ |

CI는 GitHub의 `macos-26` 러너 이미지에 포함된 기본 Xcode로 빌드합니다. 패키지는 Xcode 27로 개발합니다.

## 아키텍처

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

- `Sources/MobileLogger`에는 로거, 레코드 타입, sink(`Sinks/`), 내보내기(`Export/`)가 있습니다. `Sources/MobileLoggerSwiftLog`에는 swift-log 핸들러가 있으며, swift-log를 사용하지 않는 앱이 링크하지 않도록 별도의 제품으로 분리되어 있습니다.
- 마스킹은 어떤 sink가 호출되기 전에, 로그를 남기는 스레드에서 한 번만 일어납니다. sink는 `LogRecord` 값만 보게 되므로, 새로 만든 sink가 마스커가 숨긴 내용을 유출할 수 없습니다.
- URL과 본문은 먼저 각자의 파서로 마스킹됩니다. 그다음 metadata JSON을 그 자리에 마스킹된 텍스트를 넣어 읽으므로, URL이나 본문도 다른 문자열처럼 이웃 값을 숨깁니다. 이어서 그 자리에 표지 단어를 넣어 한 번 더 읽습니다. 그 단어가 바뀌지 않고 돌아온 곳(그 키와 이웃 값이 아무것도 숨기지 않은 곳)에서만 URL이나 본문의 텍스트가 남습니다. 그 밖의 모든 곳에서는 값이 숨겨진 채로 남습니다.
- 모든 한도는 fail-closed입니다. 한도를 넘으면 로거는 더 많이 숨기거나 버리며 결코 덜 숨기지 않고, 버린 것의 수를 셉니다.
- 테스트는 Swift Testing을 사용하며 macOS와 iPhone 시뮬레이터에서 실행됩니다. 사양의 필수 세트와 코퍼스, metadata 파이프라인, 저장소, 내보내기, swift-log 브리지, README 예제, 그리고 `OSLogStore`를 통한 unified logging 왕복 테스트를 다룹니다.

테스트를 로컬에서 실행하세요.

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 로드맵

- 예제 앱의 목록을 바탕으로 만든, 바로 쓸 수 있는 SwiftUI 로그 뷰어.
- `FileLogStore`에 크기와 개수 한도와 함께 쓸 시간 기반 보존 기간.
- 패키지를 Swift Package Index에 추가하기. `.spi.yml`은 이미 저장소에 있습니다.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
