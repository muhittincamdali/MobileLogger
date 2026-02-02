import Foundation

// MARK: - LogEntry

/// A structured log entry that captures everything about a single log event.
///
/// Each entry records the message, severity level, optional metadata,
/// and source-code location where the log call originated.
///
/// ```swift
/// let entry = LogEntry(
///     level: .info,
///     message: "User signed in",
///     metadata: ["userId": "42"],
///     file: #file,
///     function: #function,
///     line: #line
/// )
/// ```
public struct LogEntry: Sendable, Codable, Identifiable {

    /// Stable unique identifier for the entry.
    public let id: UUID

    /// The moment this log entry was created.
    public let timestamp: Date

    /// Severity level of the entry.
    public let level: LogLevel

    /// The human-readable log message.
    public let message: String

    /// Optional key-value pairs providing structured context.
    public let metadata: [String: String]?

    /// The source file where the log call was made.
    public let file: String

    /// The function name where the log call was made.
    public let function: String

    /// The line number where the log call was made.
    public let line: UInt

    // MARK: - Initializer

    /// Creates a new log entry.
    ///
    /// - Parameters:
    ///   - level: The severity level.
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata dictionary.
    ///   - file: Source file (defaults to `#file`).
    ///   - function: Function name (defaults to `#function`).
    ///   - line: Line number (defaults to `#line`).
    public init(
        level: LogLevel,
        message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
}

// MARK: - Convenience

extension LogEntry {

    /// Returns just the filename component without the full path.
    public var fileName: String {
        (file as NSString).lastPathComponent
    }

    /// A compact source location string like `"ViewController.swift:42"`.
    public var sourceLocation: String {
        "\(fileName):\(line)"
    }
}
