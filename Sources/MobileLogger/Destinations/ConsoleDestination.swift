import Foundation

// MARK: - ConsoleDestination

/// A log destination that prints formatted entries to the standard output.
///
/// By default it uses ``PrettyFormatter`` for human-readable output.
/// Attach a ``PrivacyRedactor`` to mask sensitive data before printing.
///
/// ```swift
/// let console = ConsoleDestination()
/// console.minimumLevel = .debug
/// logger.addDestination(console)
/// ```
public final class ConsoleDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum severity level to print. Defaults to ``LogLevel/trace``.
    public var minimumLevel: LogLevel = .trace

    /// Formatter used to render entries. Defaults to ``PrettyFormatter``.
    public var formatter: LogFormatter = PrettyFormatter()

    // MARK: - Configuration

    /// Optional redactor for masking PII in console output.
    public var redactor: PrivacyRedactor?

    /// Whether to include the source location (file:line) in output.
    public var showSourceLocation: Bool = true

    /// Whether to include the timestamp in output.
    public var showTimestamp: Bool = true

    /// Whether to use emoji prefixes for log levels.
    public var useEmoji: Bool = true

    // MARK: - Private

    /// Serialization queue for thread-safe printing.
    private let queue = DispatchQueue(label: "com.mobilelogger.console", qos: .utility)

    /// Date formatter for timestamps.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Initialization

    /// Creates a new console destination.
    ///
    /// - Parameter minimumLevel: The minimum level to print (default `.trace`).
    public init(minimumLevel: LogLevel = .trace) {
        self.minimumLevel = minimumLevel
    }

    // MARK: - LogDestination

    /// Prints the log entry to standard output.
    ///
    /// - Parameter entry: The log entry to print.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        queue.async { [self] in
            var output = formatter.format(entry)

            if let redactor = self.redactor {
                output = redactor.redact(output)
            }

            var components: [String] = []

            if self.showTimestamp {
                components.append(self.dateFormatter.string(from: entry.timestamp))
            }

            if self.useEmoji {
                components.append(entry.level.emoji)
            }

            components.append("[\(entry.level.label)]")

            if self.showSourceLocation {
                components.append("[\(entry.sourceLocation)]")
            }

            components.append(output)

            let line = components.joined(separator: " ")
            print(line)
        }
    }
}
