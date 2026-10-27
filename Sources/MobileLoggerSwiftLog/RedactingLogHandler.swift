import Logging
import MobileLogger

/// A swift-log `LogHandler` that sends every message through a ``MobileLogger/MobileLogger``,
/// so the logs of packages that use swift-log are redacted and stored like your own.
///
/// Bootstrap swift-log once, early in the app's life:
///
/// ```swift
/// import Logging
/// import MobileLogger
/// import MobileLoggerSwiftLog
///
/// let store = MemoryLogStore()
/// let base = MobileLogger(sinks: [OSLogSink(), store])
/// LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }
/// ```
///
/// The label of each swift-log `Logger` becomes the category. Metadata of every kind
/// (`.string`, `.stringConvertible`, `.array`, `.dictionary`) is redacted with the message;
/// a swift-log metadata provider is read too. The level is swift-log's, and the base logger's
/// ``MobileLogger/MobileLogger/minimumLevel`` applies on top of it.
public struct RedactingLogHandler: LogHandler {
    /// The logger that redacts and writes the messages, with the label as its category.
    public let logger: MobileLogger

    public var metadata: Logging.Logger.Metadata = [:]
    public var logLevel: Logging.Logger.Level
    public var metadataProvider: Logging.Logger.MetadataProvider?

    /// Creates a handler for one swift-log `Logger`.
    ///
    /// - Parameters:
    ///   - label: The swift-log label; it becomes the category.
    ///   - logger: The logger whose subsystem, policy and sinks are used.
    ///   - logLevel: The lowest swift-log level passed on; `debug` by default.
    ///   - metadataProvider: Metadata added to every message, such as a trace identifier.
    public init(
        label: String, logger: MobileLogger, logLevel: Logging.Logger.Level = .debug,
        metadataProvider: Logging.Logger.MetadataProvider? = LoggingSystem.metadataProvider
    ) {
        self.logger = logger.withCategory(label)
        self.logLevel = logLevel
        self.metadataProvider = metadataProvider
    }

    public subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(event: LogEvent) {
        var merged = metadata
        if let provided = metadataProvider?.get() { merged.merge(provided) { _, new in new } }
        if let given = event.metadata { merged.merge(given) { _, new in new } }
        var values = merged.mapValues { Self.value($0) }
        if let error = event.error { values["error"] = .error(error) }
        logger.log(
            LogLevel(event.level), event.message.description, metadata: values,
            fileID: event.file, function: event.function, line: Int(clamping: event.line)
        )
    }

    /// The ``LogValue`` for a swift-log metadata value. Nesting deeper than the 64 levels the
    /// redactor reads is cut off as `[redacted]` here, before it is walked.
    static func value(_ value: Logging.Logger.Metadata.Value, depth: Int = 1) -> LogValue {
        switch value {
        case .string(let text): return .string(text)
        case .stringConvertible(let convertible): return .string(convertible.description)
        case .array where depth > maximumDepth, .dictionary where depth > maximumDepth: return .string(RedactionPolicy.replacement)
        case .array(let elements): return .array(elements.map { Self.value($0, depth: depth + 1) })
        case .dictionary(let members): return .dictionary(members.mapValues { Self.value($0, depth: depth + 1) })
        }
    }

    /// The deepest metadata read: the levels of the spec's JSON limit, less the metadata object.
    static let maximumDepth = 63
}

extension LogLevel {
    /// The level that matches a swift-log level; they are the same seven.
    public init(_ level: Logging.Logger.Level) {
        switch level {
        case .trace: self = .trace
        case .debug: self = .debug
        case .info: self = .info
        case .notice: self = .notice
        case .warning: self = .warning
        case .error: self = .error
        case .critical: self = .critical
        }
    }
}
