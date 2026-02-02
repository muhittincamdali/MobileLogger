# MobileLogger

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%20|%20macOS%2013%20|%20tvOS%2015%20|%20watchOS%208-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight, privacy-first structured logging framework for Apple platforms. Ships with multiple destinations (console, file, OSLog, remote HTTP), automatic PII redaction, crash reporting, and performance tracking — all in a clean, extensible architecture.

---

## Features

| Feature | Description |
|---------|-------------|
| 🎯 **Multiple Log Levels** | `trace`, `debug`, `info`, `warning`, `error`, `critical` |
| 📡 **Pluggable Destinations** | Console, File (with rotation), OSLog, Remote HTTP |
| 🔒 **Privacy Redaction** | Automatic masking of emails, phone numbers, and IP addresses |
| 📊 **Performance Tracking** | Measure execution time of any code block |
| 💥 **Crash Reporting** | Catch uncaught exceptions and signals |
| 🎨 **Flexible Formatters** | JSON and pretty-print formatters, or build your own |
| 🧵 **Thread-Safe** | All operations are serialized on a dedicated queue |
| 📦 **Zero Dependencies** | Pure Swift, no third-party packages |

---

## Requirements

- iOS 15.0+ / macOS 13.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

---

## Installation

### Swift Package Manager

Add MobileLogger to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/MobileLogger.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repository URL.

---

## Quick Start

### Basic Usage

```swift
import MobileLogger

// Get the shared logger
let logger = Logger.shared

// Add a console destination
logger.addDestination(ConsoleDestination())

// Start logging
logger.debug("App launched")
logger.info("User signed in", metadata: ["userId": "12345"])
logger.warning("Cache miss for key", metadata: ["key": "user_profile"])
logger.error("Network request failed", metadata: ["statusCode": "500"])
```

### Multiple Destinations

```swift
let logger = Logger.shared

// Console with pretty formatting
let console = ConsoleDestination()
console.formatter = PrettyFormatter()
console.minimumLevel = .debug
logger.addDestination(console)

// File with rotation (max 5 MB per file)
let file = FileDestination(
    fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("app.log"),
    maxFileSize: 5_000_000,
    maxRotatedFiles: 3
)
file.formatter = JSONFormatter()
logger.addDestination(file)

// Apple's unified logging via OSLog
let oslog = OSLogDestination(subsystem: "com.myapp", category: "general")
logger.addDestination(oslog)

// Remote endpoint
let remote = RemoteDestination(
    endpointURL: URL(string: "https://logs.example.com/ingest")!,
    batchSize: 20,
    flushInterval: 30
)
logger.addDestination(remote)
```

### Privacy Redaction

```swift
let redactor = PrivacyRedactor()

// Automatically redacts PII
let safe = redactor.redact("Contact me at john@example.com or 555-123-4567")
// "Contact me at [REDACTED_EMAIL] or [REDACTED_PHONE]"

// Enable on a destination
let console = ConsoleDestination()
console.redactor = PrivacyRedactor()
logger.addDestination(console)
```

### @Sensitive Property Wrapper

```swift
struct UserProfile {
    let id: String
    @Sensitive var email: String
    @Sensitive var phoneNumber: String
}

let user = UserProfile(id: "42", email: "jane@example.com", phoneNumber: "555-987-6543")
print(user.email) // "[REDACTED]"
print(user.$email) // "jane@example.com" (projected value = raw)
```

### Performance Tracking

```swift
let tracker = PerformanceTracker(logger: Logger.shared)

// Measure a synchronous block
let result = tracker.measure("database_query") {
    database.fetchAllUsers()
}

// Measure an async operation
let data = await tracker.measureAsync("api_call") {
    try await api.fetchUserProfile()
}

// Manual start/stop
let token = tracker.start("image_processing")
// ... do work ...
tracker.stop(token)
```

### Crash Reporting

```swift
let reporter = CrashReporter(logger: Logger.shared)
reporter.install()

// Uncaught exceptions and signals (SIGABRT, SIGSEGV, etc.)
// are automatically captured and logged before the app exits.

// You can also add a callback
reporter.onCrash = { entry in
    // Flush logs, send analytics, etc.
}
```

---

## Architecture

```
MobileLogger/
├── Core/
│   ├── Logger.swift            # Central logger with destination management
│   ├── LogLevel.swift          # Log severity enum
│   ├── LogEntry.swift          # Structured log entry model
│   └── LogDestination.swift    # Destination protocol
├── Destinations/
│   ├── ConsoleDestination       # Print-based console output
│   ├── FileDestination          # File logging with rotation
│   ├── OSLogDestination         # Apple OSLog bridge
│   └── RemoteDestination        # HTTP POST log shipping
├── Formatters/
│   ├── LogFormatter             # Formatter protocol
│   ├── JSONFormatter            # Machine-readable JSON
│   └── PrettyFormatter          # Human-readable colored output
├── Privacy/
│   ├── PrivacyRedactor          # PII detection and masking
│   └── SensitiveData            # @Sensitive property wrapper
└── Performance/
    ├── CrashReporter            # Exception/signal handler
    └── PerformanceTracker       # Execution time measurement
```

---

## Custom Destinations

Implement `LogDestination` to create your own:

```swift
final class SlackDestination: LogDestination {
    var minimumLevel: LogLevel = .error
    var formatter: LogFormatter = JSONFormatter()

    func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }
        let message = formatter.format(entry)
        // POST to Slack webhook...
    }
}
```

## Custom Formatters

Implement `LogFormatter`:

```swift
struct CSVFormatter: LogFormatter {
    func format(_ entry: LogEntry) -> String {
        let timestamp = ISO8601DateFormatter().string(from: entry.timestamp)
        return "\(timestamp),\(entry.level.rawValue),\"\(entry.message)\""
    }
}
```

---

## Log Levels

| Level | Value | Usage |
|-------|-------|-------|
| `trace` | 0 | Granular debugging, function entry/exit |
| `debug` | 1 | Development-time diagnostics |
| `info` | 2 | General informational messages |
| `warning` | 3 | Potential issues that deserve attention |
| `error` | 4 | Recoverable errors |
| `critical` | 5 | Fatal errors, app is about to crash |

---

## Thread Safety

`Logger` serializes all write operations through a dedicated `DispatchQueue`. Reads from the log buffer are synchronized as well. You can safely call logging methods from any thread or queue.

---

## Best Practices

1. **Set minimum levels per destination** — keep `trace`/`debug` on console only.
2. **Enable privacy redaction** on any destination that might be inspected by third parties.
3. **Use metadata** generously — structured key-value pairs make searching logs trivial.
4. **Rotate file logs** — set `maxFileSize` and `maxRotatedFiles` to avoid filling disk.
5. **Batch remote logs** — `RemoteDestination` batches by default to reduce network overhead.
6. **Install `CrashReporter` early** — call `install()` in `application(_:didFinishLaunchingWithOptions:)`.

---

## FAQ

**Q: Does MobileLogger work with SwiftUI previews?**
A: Yes. `ConsoleDestination` works perfectly in previews. Avoid `FileDestination` in previews since the sandbox may be restricted.

**Q: Can I use it in an App Extension?**
A: Absolutely. All destinations work in extensions. For shared logs between app and extension, point `FileDestination` at an App Group container.

**Q: How do I filter logs at runtime?**
A: Set `Logger.shared.minimumLevel` globally, or set `minimumLevel` on individual destinations for fine-grained control.

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please follow the existing code style and add tests for new features.

---

## License

MobileLogger is available under the MIT license. See the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the Apple developer community**
