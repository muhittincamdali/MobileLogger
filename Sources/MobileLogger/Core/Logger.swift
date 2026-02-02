import Foundation

// MARK: - Logger

/// The central logging engine that routes log entries to registered destinations.
///
/// `Logger` manages a collection of ``LogDestination`` instances and dispatches
/// each log entry to every destination whose ``LogDestination/minimumLevel``
/// is met. All operations are thread-safe via a serial dispatch queue.
///
/// ## Usage
///
/// ```swift
/// let logger = Logger.shared
/// logger.addDestination(ConsoleDestination())
/// logger.info("Application started")
/// ```
///
/// ## Minimum Level
///
/// Set ``minimumLevel`` to filter entries globally before they reach any
/// destination. Each destination can further refine filtering with its own level.
public final class Logger: @unchecked Sendable {

    // MARK: - Shared Instance

    /// The default shared logger instance.
    public static let shared = Logger()

    // MARK: - Properties

    /// Global minimum log level. Entries below this are discarded before
    /// reaching any destination.
    public var minimumLevel: LogLevel = .trace

    /// Whether logging is enabled. Set to `false` to silence all output.
    public var isEnabled: Bool = true

    /// Optional privacy redactor applied to all entries before dispatching.
    public var redactor: PrivacyRedactor?

    /// A label identifying this logger instance.
    public let label: String

    // MARK: - Private

    /// Serial queue ensuring thread-safe access to destinations and buffer.
    private let queue = DispatchQueue(label: "com.mobilelogger.serial", qos: .utility)

    /// Registered destinations.
    private var destinations: [LogDestination] = []

    /// In-memory ring buffer of recent entries.
    private var buffer: [LogEntry] = []

    /// Maximum number of entries retained in the ring buffer.
    private let bufferCapacity: Int

    // MARK: - Initialization

    /// Creates a new logger.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the logger.
    ///   - bufferCapacity: Maximum entries held in memory (default 500).
    public init(label: String = "com.mobilelogger.default", bufferCapacity: Int = 500) {
        self.label = label
        self.bufferCapacity = bufferCapacity
    }

    // MARK: - Destination Management

    /// Registers a new destination.
    ///
    /// - Parameter destination: The destination to add.
    public func addDestination(_ destination: LogDestination) {
        queue.sync {
            destinations.append(destination)
        }
    }

    /// Removes all registered destinations.
    public func removeAllDestinations() {
        queue.sync {
            destinations.removeAll()
        }
    }

    /// Returns the number of currently registered destinations.
    public var destinationCount: Int {
        queue.sync { destinations.count }
    }

    // MARK: - Buffer Access

    /// Returns a snapshot of the in-memory log buffer.
    public var recentEntries: [LogEntry] {
        queue.sync { buffer }
    }

    /// Clears the in-memory log buffer.
    public func clearBuffer() {
        queue.sync { buffer.removeAll() }
    }

    // MARK: - Logging Methods

    /// Logs a message at the ``LogLevel/trace`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func trace(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .trace, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a message at the ``LogLevel/debug`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func debug(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a message at the ``LogLevel/info`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func info(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a message at the ``LogLevel/warning`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func warning(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warning, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a message at the ``LogLevel/error`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func error(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a message at the ``LogLevel/critical`` level.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file (auto-captured).
    ///   - function: Function name (auto-captured).
    ///   - line: Line number (auto-captured).
    public func critical(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .critical, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    // MARK: - Core Dispatch

    /// The central logging method that all convenience methods funnel through.
    ///
    /// - Parameters:
    ///   - level: Severity level.
    ///   - message: The log message.
    ///   - metadata: Optional structured metadata.
    ///   - file: Source file.
    ///   - function: Function name.
    ///   - line: Line number.
    public func log(
        level: LogLevel,
        message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard isEnabled, level >= minimumLevel else { return }

        let finalMessage: String
        if let redactor = redactor {
            finalMessage = redactor.redact(message)
        } else {
            finalMessage = message
        }

        let entry = LogEntry(
            level: level,
            message: finalMessage,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )

        queue.async { [weak self] in
            guard let self else { return }
            self.appendToBuffer(entry)
            self.dispatchToDestinations(entry)
        }
    }

    // MARK: - Private Helpers

    /// Appends an entry to the ring buffer, evicting the oldest if full.
    private func appendToBuffer(_ entry: LogEntry) {
        buffer.append(entry)
        if buffer.count > bufferCapacity {
            buffer.removeFirst(buffer.count - bufferCapacity)
        }
    }

    /// Sends an entry to all destinations whose minimum level is met.
    private func dispatchToDestinations(_ entry: LogEntry) {
        for destination in destinations where entry.level >= destination.minimumLevel {
            destination.send(entry)
        }
    }
}
