import Foundation

// MARK: - LogLevel

/// Represents the severity of a log message.
///
/// Log levels are ordered by severity from ``trace`` (least severe)
/// to ``critical`` (most severe). Use these to filter noise and
/// surface only the messages that matter for a given context.
///
/// ```swift
/// let level: LogLevel = .warning
/// print(level.emoji) // "⚠️"
/// ```
public enum LogLevel: Int, Codable, Sendable, CaseIterable {

    /// Granular debugging information — function entry/exit, variable dumps.
    case trace = 0

    /// Development-time diagnostic messages.
    case debug = 1

    /// General informational messages about application flow.
    case info = 2

    /// Potential issues that deserve attention but are not errors.
    case warning = 3

    /// Recoverable errors that affected a specific operation.
    case error = 4

    /// Fatal errors — the application is about to crash or is in an unrecoverable state.
    case critical = 5
}

// MARK: - Comparable

extension LogLevel: Comparable {

    /// Compares two log levels by their raw integer value.
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Display Helpers

extension LogLevel {

    /// A short uppercase label for the level (e.g. `"TRACE"`, `"ERROR"`).
    public var label: String {
        switch self {
        case .trace:    return "TRACE"
        case .debug:    return "DEBUG"
        case .info:     return "INFO"
        case .warning:  return "WARNING"
        case .error:    return "ERROR"
        case .critical: return "CRITICAL"
        }
    }

    /// An emoji representation for visual scanning in console output.
    public var emoji: String {
        switch self {
        case .trace:    return "🔍"
        case .debug:    return "🐛"
        case .info:     return "ℹ️"
        case .warning:  return "⚠️"
        case .error:    return "❌"
        case .critical: return "🔥"
        }
    }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {

    /// Returns the lowercase name of the level.
    public var description: String {
        label.lowercased()
    }
}
