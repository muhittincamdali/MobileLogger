import Foundation

// MARK: - CrashReporter

/// Captures uncaught exceptions and POSIX signals, logging them before the
/// process terminates.
///
/// Install the reporter as early as possible in the application lifecycle
/// (e.g. in `application(_:didFinishLaunchingWithOptions:)`).
///
/// ```swift
/// let reporter = CrashReporter(logger: Logger.shared)
/// reporter.install()
/// ```
///
/// > Important: Signal handlers are process-global. Installing this reporter
/// > replaces any previously registered handlers for the monitored signals.
public final class CrashReporter: @unchecked Sendable {

    // MARK: - Properties

    /// The logger instance used to record crash information.
    public let logger: Logger

    /// Callback invoked with the crash log entry just before the process exits.
    public var onCrash: ((LogEntry) -> Void)?

    /// Whether the reporter has been installed.
    public private(set) var isInstalled: Bool = false

    /// Signals to monitor.
    private let monitoredSignals: [Int32] = [
        SIGABRT,
        SIGSEGV,
        SIGBUS,
        SIGFPE,
        SIGILL,
        SIGTRAP
    ]

    /// Storage for previous signal handlers so they can be chained.
    private var previousHandlers: [Int32: (@convention(c) (Int32) -> Void)?] = [:]

    // MARK: - Singleton Reference

    /// Static reference so the C signal handler can reach the instance.
    private static var current: CrashReporter?

    // MARK: - Initialization

    /// Creates a new crash reporter.
    ///
    /// - Parameter logger: The logger to write crash entries to.
    public init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Installation

    /// Installs the exception and signal handlers.
    ///
    /// Safe to call multiple times — subsequent calls are no-ops.
    public func install() {
        guard !isInstalled else { return }
        isInstalled = true
        Self.current = self

        // Uncaught Objective-C exceptions
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.handleException(exception)
        }

        // POSIX signals
        for sig in monitoredSignals {
            let previous = signal(sig, CrashReporter.signalHandler)
            previousHandlers[sig] = previous
        }
    }

    /// Removes the installed handlers.
    public func uninstall() {
        guard isInstalled else { return }
        isInstalled = false

        NSSetUncaughtExceptionHandler(nil)

        for sig in monitoredSignals {
            if let previous = previousHandlers[sig] {
                signal(sig, previous)
            } else {
                signal(sig, SIG_DFL)
            }
        }

        previousHandlers.removeAll()
        Self.current = nil
    }

    // MARK: - Handlers

    /// Handles an uncaught NSException.
    private static func handleException(_ exception: NSException) {
        guard let reporter = current else { return }

        let symbols = exception.callStackSymbols.joined(separator: "\n")
        let message = """
        Uncaught Exception: \(exception.name.rawValue)
        Reason: \(exception.reason ?? "unknown")
        Stack Trace:
        \(symbols)
        """

        let entry = LogEntry(
            level: .critical,
            message: message,
            metadata: [
                "exceptionName": exception.name.rawValue,
                "reason": exception.reason ?? "unknown"
            ]
        )

        reporter.logger.log(level: .critical, message: message)
        reporter.onCrash?(entry)
    }

    /// C-compatible signal handler function.
    private static let signalHandler: @convention(c) (Int32) -> Void = { sig in
        guard let reporter = current else { return }

        let name = signalName(sig)
        let symbols = Thread.callStackSymbols.joined(separator: "\n")
        let message = """
        Signal received: \(name) (\(sig))
        Stack Trace:
        \(symbols)
        """

        let entry = LogEntry(
            level: .critical,
            message: message,
            metadata: [
                "signal": name,
                "signalCode": "\(sig)"
            ]
        )

        reporter.logger.log(level: .critical, message: message)
        reporter.onCrash?(entry)

        // Re-raise with default handler so the OS can produce a crash report
        signal(sig, SIG_DFL)
        raise(sig)
    }

    /// Returns a human-readable name for a signal number.
    private static func signalName(_ sig: Int32) -> String {
        switch sig {
        case SIGABRT: return "SIGABRT"
        case SIGSEGV: return "SIGSEGV"
        case SIGBUS:  return "SIGBUS"
        case SIGFPE:  return "SIGFPE"
        case SIGILL:  return "SIGILL"
        case SIGTRAP: return "SIGTRAP"
        default:      return "SIGNAL(\(sig))"
        }
    }
}
