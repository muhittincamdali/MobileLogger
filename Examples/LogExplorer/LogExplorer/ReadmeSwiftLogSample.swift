// The swift-log sample of README.md. The example app compiles this file, and so does the
// package's swift-log test target through the symlink
// Tests/MobileLoggerSwiftLogTests/ReadmeSwiftLogExample.swift.
import Logging
import MobileLogger
import MobileLoggerSwiftLog

/// Sends the logs of every package that uses swift-log through the redactor. Call it once,
/// early in the app's life: swift-log accepts one bootstrap per process.
func bootstrapSwiftLog(store: MemoryLogStore) {
    let base = MobileLogger(sinks: [OSLogSink(), store])
    LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }

    let logger = Logger(label: "com.example.sync")
    logger.info("Sync finished", metadata: ["token": "abc123", "items": "42"])
    // Sync finished {"items":"42","token":"[redacted]"}
}
