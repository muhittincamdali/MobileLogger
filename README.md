<p align="center">
  <img src="Assets/logo.png" alt="MobileLogger" width="200"/>
</p>

<h1 align="center">MobileLogger</h1>

<p align="center">
  <strong>📝 Cross-platform structured logging framework for iOS with OSLog integration</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+"/>
</p>

---

## Why MobileLogger?

iOS has `os_log` but it's verbose. Third-party loggers lack system integration. **MobileLogger** combines the best of both - simple API, OSLog integration, structured logging, and remote capabilities.

```swift
// Simple and powerful
Log.info("User logged in", metadata: ["userId": user.id])
Log.error("Payment failed", error: error, metadata: ["amount": 99.99])

// Automatically includes:
// - Timestamp
// - File/function/line
// - Thread info
// - Device context
```

## Features

| Feature | Description |
|---------|-------------|
| 📊 **Structured** | Key-value metadata support |
| 🔍 **OSLog Native** | Console.app integration |
| 🎯 **Log Levels** | debug, info, warning, error, critical |
| 📤 **Remote Upload** | Send logs to backend |
| 💾 **Persistence** | File-based log storage |
| 🔐 **Privacy** | Automatic PII redaction |
| 📱 **Context** | Device, OS, app info |

## Quick Start

```swift
import MobileLogger

// Configure once
Log.configure {
    $0.minimumLevel = .debug
    $0.destinations = [.console, .file, .remote(url: logServerURL)]
    $0.includeContext = true
}

// Use anywhere
Log.debug("Starting operation")
Log.info("User action", metadata: ["screen": "home"])
Log.warning("Slow response", metadata: ["duration": 2.5])
Log.error("Request failed", error: error)
Log.critical("Database corrupted")
```

## Log Levels

| Level | Use Case |
|-------|----------|
| `debug` | Development info, disabled in release |
| `info` | Normal operations |
| `warning` | Potential issues |
| `error` | Recoverable errors |
| `critical` | App-breaking issues |

## Structured Logging

```swift
Log.info("Purchase completed", metadata: [
    "productId": product.id,
    "amount": order.total,
    "currency": "USD",
    "userId": user.id.redacted // PII protection
])

// Output:
// [INFO] Purchase completed
// {
//   "productId": "SKU123",
//   "amount": 99.99,
//   "currency": "USD",
//   "userId": "<redacted>"
// }
```

## Remote Logging

```swift
Log.configure {
    $0.destinations = [
        .console,
        .remote(
            url: URL(string: "https://logs.myapp.com/ingest")!,
            batchSize: 50,
            flushInterval: 30
        )
    ]
}
```

## Console.app Integration

View logs in Console.app with:
- Category filtering
- Subsystem grouping
- Live streaming
- Search and filter

## Best Practices

```swift
// ✅ Good: Structured metadata
Log.info("API response", metadata: ["status": 200, "duration": 0.5])

// ❌ Avoid: String interpolation
Log.info("API response: status=200, duration=0.5")
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License
