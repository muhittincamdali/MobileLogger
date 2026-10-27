import Foundation
import Synchronization
@testable import MobileLogger

/// A sink that keeps what it receives, for assertions.
final class CollectingSink: LogSink {
    private let received = Mutex<[LogRecord]>([])

    func write(_ record: LogRecord) {
        received.withLock { $0.append(record) }
    }

    var records: [LogRecord] {
        received.withLock { $0 }
    }
}

let replacement = "[redacted]"

/// The record a logger with `policy` makes for a message and metadata.
func record(_ message: String = "event", metadata: LogMetadata = [:], policy: RedactionPolicy = RedactionPolicy()) -> LogRecord {
    MobileLogger(category: "Tests", policy: policy, sinks: []).makeRecord(
        level: .info, message: message, metadata: metadata, source: LogRecord.Source(fileID: "Tests/TestSupport.swift", function: "record", line: 1)
    )
}

/// The redacted message for `text`.
func redactedMessage(_ text: String, policy: RedactionPolicy = RedactionPolicy()) -> String {
    record(text, policy: policy).message
}

/// The redacted metadata value for one key.
func redactedValue(_ value: LogValue, key: String = "value", policy: RedactionPolicy = RedactionPolicy()) -> RedactedValue? {
    record(metadata: [key: value], policy: policy).metadata[key]
}

/// A body as metadata, redacted: the string written for it.
func redactedBody(_ text: String, contentType: String?) -> String? {
    redactedValue(.body(Data(text.utf8), contentType: contentType), key: "body")?.stringValue
}

/// A URL as metadata, redacted.
func redactedURL(_ text: String, policy: RedactionPolicy = RedactionPolicy()) -> String? {
    guard let url = URL(string: text) else { return nil }
    return redactedValue(.url(url), key: "url", policy: policy)?.stringValue
}

/// A folder of its own for one test, removed by the caller.
func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appending(path: "MobileLoggerTests-\(UUID().uuidString)", directoryHint: .isDirectory)
}

extension LogRecord {
    static func sample(_ message: String = "event", level: LogLevel = .info, date: Date = Date(), metadata: [String: RedactedValue] = [:]) -> LogRecord {
        LogRecord(
            date: date, level: level, subsystem: "io.github.muhittincamdali.tests", category: "Tests", message: message, metadata: metadata,
            source: LogRecord.Source(fileID: "MobileLoggerTests/TestSupport.swift", function: "sample", line: 1)
        )
    }
}
