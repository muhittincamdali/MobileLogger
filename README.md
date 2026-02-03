<div align="center">

# 📝 MobileLogger

**Cross-platform structured logging framework for iOS with OSLog integration**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 📊 **Structured Logging** — Key-value metadata
- 🍎 **OSLog** — Native Apple unified logging
- 📁 **File Export** — Log to files
- 🔒 **Privacy** — Automatic PII redaction
- 🎨 **Customizable** — Formatters & filters

---

## 🚀 Quick Start

```swift
import MobileLogger

let log = Logger(subsystem: "com.app", category: "network")

log.debug("Request started", metadata: ["url": url])
log.info("User logged in", metadata: ["userId": user.id])
log.error("Request failed", error: error)

// Privacy-aware
log.info("User: \(username, privacy: .private)")
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
