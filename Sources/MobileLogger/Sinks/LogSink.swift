/// A destination for redacted log records.
///
/// ``MobileLogger`` calls ``write(_:)`` on the thread that logs, after redaction, so a sink only
/// ever sees a ``LogRecord``, never the raw message. Return quickly: do slow work, such as disk
/// or network writes, on a queue of your own, with a bound on what waits.
///
/// ```swift
/// struct CrashReporterBreadcrumbs: LogSink {
///     func write(_ record: LogRecord) {
///         guard record.level >= .warning else { return }
///         Breadcrumbs.add(record.message)   // already redacted
///     }
/// }
/// ```
public protocol LogSink: Sendable {
    /// Receives one record.
    func write(_ record: LogRecord)
}

/// A sink whose records can be read back, for an export or an in-app log screen.
public protocol LogRecordSource: Sendable {
    /// The records kept, oldest first.
    func records() async throws -> [LogRecord]
}
