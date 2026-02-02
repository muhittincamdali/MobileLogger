import Foundation
import os.log

// MARK: - OSLogDestination

/// A log destination that bridges to Apple's unified logging system (OSLog).
///
/// Maps ``LogLevel`` values to the corresponding `OSLogType` so that
/// entries appear correctly in Console.app and Instruments.
///
/// ```swift
/// let oslog = OSLogDestination(subsystem: "com.myapp", category: "network")
/// logger.addDestination(oslog)
/// ```
public final class OSLogDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum severity level. Defaults to ``LogLevel/debug``.
    public var minimumLevel: LogLevel = .debug

    /// Formatter used to render the message portion. Defaults to ``PrettyFormatter``.
    public var formatter: LogFormatter = PrettyFormatter()

    // MARK: - Properties

    /// The OSLog instance used for writing.
    private let osLog: OSLog

    /// The subsystem identifier (typically your bundle identifier).
    public let subsystem: String

    /// The category within the subsystem.
    public let category: String

    // MARK: - Initialization

    /// Creates a new OSLog destination.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem string (e.g. `"com.myapp"`).
    ///   - category: The category string (e.g. `"networking"`).
    public init(subsystem: String, category: String = "default") {
        self.subsystem = subsystem
        self.category = category
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }

    // MARK: - LogDestination

    /// Sends the log entry through Apple's unified logging system.
    ///
    /// - Parameter entry: The log entry to log.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        let message = formatter.format(entry)
        let type = osLogType(for: entry.level)

        os_log("%{public}@", log: osLog, type: type, message)
    }

    // MARK: - Private Helpers

    /// Maps a ``LogLevel`` to the corresponding `OSLogType`.
    ///
    /// - Parameter level: The log level to convert.
    /// - Returns: The matching `OSLogType`.
    private func osLogType(for level: LogLevel) -> OSLogType {
        switch level {
        case .trace:
            return .debug
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}
