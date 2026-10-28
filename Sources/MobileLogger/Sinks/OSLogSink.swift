import os

/// Writes records to unified logging (`os.Logger`), where Xcode's console, Console.app and
/// `log stream` show them.
///
/// The text is already redacted, so it is written as public by default: unified logging
/// otherwise hides every dynamic value as `<private>` when no debugger is attached, which makes
/// the logs of a sysdiagnose or a `log collect` archive useless. Pass `.private` to keep the
/// operating system's own hiding as well.
///
/// Each record becomes one line: the message, then the metadata as compact JSON with sorted
/// keys, such as `Request finished {"status":200,"url":"https://api.example.com/users/:id"}`.
public struct OSLogSink: LogSink {
    /// Whether unified logging shows the text when no debugger is attached.
    public enum Visibility: Sendable, Hashable {
        /// The redacted text is shown everywhere.
        case `public`
        /// The text is shown while a debugger is attached and `<private>` otherwise.
        case `private`
    }

    public let visibility: Visibility

    public init(visibility: Visibility = .public) {
        self.visibility = visibility
    }

    public func write(_ record: LogRecord) {
        let logger = os.Logger(subsystem: record.subsystem, category: record.category)
        let text = LogFormat.messageLine(record)
        switch visibility {
        case .public: logger.log(level: record.level.osLogType, "\(text, privacy: .public)")
        case .private: logger.log(level: record.level.osLogType, "\(text, privacy: .private)")
        }
    }
}
