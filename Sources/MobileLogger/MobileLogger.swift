import Foundation

/// Writes log messages with their secrets hidden, to unified logging and to stores you can
/// export from the device.
///
/// Every message and every metadata value goes through the redactor of the shared redaction
/// spec before any sink sees it, so the same safe text reaches Console.app, the in-app store
/// and an exported file:
///
/// ```swift
/// let store = MemoryLogStore()
/// let log = MobileLogger(category: "Checkout", sinks: [OSLogSink(), store])
///
/// log.info("Payment sent", metadata: ["card": "4242 4242 4242 4242", "status": 200])
/// // Payment sent {"card":"[redacted]","status":200}
/// ```
///
/// Put data in the metadata and keep the message a constant sentence: in free text, the first
/// key that is not allowed hides the rest of the line (`user=bob` writes `user=[redacted]`),
/// while a metadata key that names no secret keeps its value.
///
/// `MobileLogger` is a value type: copy it, change ``minimumLevel`` or ``metadata`` on the copy,
/// or make one per feature with ``withCategory(_:)``.
public struct MobileLogger: Sendable {
    /// The subsystem the app's bundle identifier gives, or `MobileLogger` without one.
    public static var defaultSubsystem: String {
        Bundle.main.bundleIdentifier ?? "MobileLogger"
    }

    /// The subsystem, usually the bundle identifier: how Console.app groups the messages.
    ///
    /// Written as given, never redacted: keep it a fixed name, never data.
    public let subsystem: String
    /// The category, such as `Network` or `Checkout`.
    ///
    /// Written as given, never redacted: keep it a fixed name, never data.
    public let category: String
    /// Messages below this level are dropped before anything is read.
    public var minimumLevel: LogLevel
    /// Metadata added to every message; a key given at the call site wins.
    public var metadata: LogMetadata
    /// Where records go.
    public let sinks: [any LogSink]
    /// What the redactor may let through.
    public let policy: RedactionPolicy

    let redactor: RecordRedactor

    /// Creates a logger.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem; the bundle identifier by default. Not redacted.
    ///   - category: The category. Not redacted.
    ///   - minimumLevel: The lowest level that is written; `debug` by default.
    ///   - metadata: Metadata added to every message.
    ///   - policy: What the redactor may let through; the spec's defaults hide the most.
    ///   - sinks: Where records go; unified logging by default.
    public init(
        subsystem: String = MobileLogger.defaultSubsystem, category: String = "App", minimumLevel: LogLevel = .debug,
        metadata: LogMetadata = [:], policy: RedactionPolicy = RedactionPolicy(), sinks: [any LogSink] = [OSLogSink()]
    ) {
        self.subsystem = subsystem
        self.category = category
        self.minimumLevel = minimumLevel
        self.metadata = metadata
        self.policy = policy
        self.sinks = sinks
        redactor = RecordRedactor(policy: policy)
    }

    /// A logger like this one with another category, which is not redacted.
    public func withCategory(_ category: String) -> MobileLogger {
        MobileLogger(subsystem: subsystem, category: category, minimumLevel: minimumLevel, metadata: metadata, policy: policy, sinks: sinks)
    }

    /// Whether a message at `level` would be written.
    public func isEnabled(_ level: LogLevel) -> Bool {
        level >= minimumLevel && !sinks.isEmpty
    }

    /// Redacts a message and its metadata and writes the record to every sink.
    ///
    /// The message and metadata are only evaluated when `level` is enabled.
    public func log(
        _ level: LogLevel, _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        guard isEnabled(level) else { return }
        let record = makeRecord(
            level: level, message: message(), metadata: metadata(), source: LogRecord.Source(fileID: fileID, function: function, line: line)
        )
        for sink in sinks {
            sink.write(record)
        }
    }

    /// The record a message and its metadata become, without writing it anywhere.
    public func makeRecord(level: LogLevel, message: String, metadata: LogMetadata, source: LogRecord.Source, date: Date = Date()) -> LogRecord {
        let merged = self.metadata.merging(metadata) { _, callSite in callSite }
        let redacted = redactor.metadata(merged)
        return LogRecord(
            date: date, level: level, subsystem: subsystem, category: category, message: redactor.message(message),
            metadata: redacted.values, omittedMetadata: redacted.omitted, source: source
        )
    }
}

extension MobileLogger {
    /// Logs step-by-step detail.
    public func trace(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.trace, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs information for debugging.
    public func debug(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.debug, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs a normal event.
    public func info(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.info, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs a normal but significant event.
    public func notice(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.notice, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs something unexpected that the app recovered from.
    public func warning(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.warning, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs a failed operation.
    public func error(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.error, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }

    /// Logs a state the app cannot continue from normally.
    public func critical(
        _ message: @autoclosure () -> String, metadata: @autoclosure () -> LogMetadata = [:],
        fileID: String = #fileID, function: String = #function, line: Int = #line
    ) {
        log(.critical, message(), metadata: metadata(), fileID: fileID, function: function, line: line)
    }
}
