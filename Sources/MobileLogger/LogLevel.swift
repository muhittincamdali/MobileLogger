import OSLog

/// How important a log message is, from ``trace`` to ``critical``.
///
/// The seven levels are the ones of swift-log's `Logger.Level`, so a ``MobileLogger`` and the
/// swift-log bridge in `MobileLoggerSwiftLog` agree on them. Levels compare by importance:
/// `LogLevel.warning > LogLevel.info`.
public enum LogLevel: String, Sendable, Codable, CaseIterable, Comparable {
    /// Step-by-step detail, usually only while tracking down one problem.
    case trace
    /// Information for developers while debugging.
    case debug
    /// Normal events worth keeping, such as a screen being shown or a request finishing.
    case info
    /// Events that are normal but significant, such as a sign-in or a purchase.
    case notice
    /// Something unexpected that the app recovered from.
    case warning
    /// An operation failed.
    case error
    /// The app cannot continue normally.
    case critical

    /// The level's position in ``allCases``, lowest first.
    var severity: Int {
        switch self {
        case .trace: 0
        case .debug: 1
        case .info: 2
        case .notice: 3
        case .warning: 4
        case .error: 5
        case .critical: 6
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.severity < rhs.severity
    }

    /// The unified logging type the level is written with.
    ///
    /// Unified logging has five types, so `trace` and `debug` share `.debug`, and `warning` and
    /// `error` share `.error`, as they do in `os.Logger`.
    public var osLogType: OSLogType {
        switch self {
        case .trace, .debug: .debug
        case .info: .info
        case .notice: .default
        case .warning, .error: .error
        case .critical: .fault
        }
    }
}
