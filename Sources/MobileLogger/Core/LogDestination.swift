import Foundation

// MARK: - LogDestination

/// A protocol that defines where log entries are sent.
///
/// Conform to this protocol to create custom destinations such as
/// database storage, analytics pipelines, or third-party services.
///
/// ```swift
/// final class MyDestination: LogDestination {
///     var minimumLevel: LogLevel = .info
///     var formatter: LogFormatter = PrettyFormatter()
///
///     func send(_ entry: LogEntry) {
///         guard entry.level >= minimumLevel else { return }
///         let output = formatter.format(entry)
///         // ... deliver output somewhere
///     }
/// }
/// ```
public protocol LogDestination: AnyObject, Sendable {

    /// The minimum log level this destination will accept.
    /// Entries below this level are silently dropped.
    var minimumLevel: LogLevel { get set }

    /// The formatter used to convert a ``LogEntry`` into a string.
    var formatter: LogFormatter { get set }

    /// Delivers a log entry to this destination.
    ///
    /// - Parameter entry: The structured log entry to process.
    func send(_ entry: LogEntry)
}
