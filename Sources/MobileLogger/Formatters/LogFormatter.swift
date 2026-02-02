import Foundation

// MARK: - LogFormatter

/// A protocol for converting a ``LogEntry`` into a string representation.
///
/// Implement this protocol to create custom output formats such as
/// CSV, XML, or any other serialization you need.
///
/// ```swift
/// struct MyFormatter: LogFormatter {
///     func format(_ entry: LogEntry) -> String {
///         "\(entry.level.label): \(entry.message)"
///     }
/// }
/// ```
public protocol LogFormatter: Sendable {

    /// Converts a log entry into a formatted string.
    ///
    /// - Parameter entry: The entry to format.
    /// - Returns: A string representation of the entry.
    func format(_ entry: LogEntry) -> String
}
