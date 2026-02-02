import Foundation

// MARK: - PerformanceTracker

/// Measures and logs the execution time of code blocks.
///
/// Provides both closure-based and manual start/stop APIs for
/// flexible performance instrumentation.
///
/// ```swift
/// let tracker = PerformanceTracker(logger: Logger.shared)
///
/// // Closure-based
/// let result = tracker.measure("fetch_users") {
///     database.fetchAllUsers()
/// }
///
/// // Manual
/// let token = tracker.start("image_resize")
/// // ... work ...
/// tracker.stop(token)
/// ```
public final class PerformanceTracker: @unchecked Sendable {

    // MARK: - Types

    /// An opaque token representing an in-progress measurement.
    public struct MeasurementToken: Sendable {
        /// The label identifying this measurement.
        public let label: String
        /// The time the measurement started.
        let startTime: CFAbsoluteTime
        /// Unique identifier for the measurement.
        let id: UUID
    }

    // MARK: - Properties

    /// The logger used to output timing results.
    public let logger: Logger

    /// The log level used for performance entries. Defaults to ``LogLevel/debug``.
    public var logLevel: LogLevel = .debug

    /// Active measurements keyed by their token ID.
    private var activeMeasurements: [UUID: MeasurementToken] = [:]

    /// Serial queue for thread safety.
    private let queue = DispatchQueue(label: "com.mobilelogger.performance", qos: .utility)

    // MARK: - Initialization

    /// Creates a new performance tracker.
    ///
    /// - Parameter logger: The logger to report timing results to.
    public init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Closure-Based Measurement

    /// Measures the execution time of a synchronous closure.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the operation.
    ///   - operation: The closure to measure.
    /// - Returns: The return value of the closure.
    @discardableResult
    public func measure<T>(_ label: String, operation: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        logDuration(label: label, elapsed: elapsed)
        return result
    }

    /// Measures the execution time of an asynchronous closure.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the operation.
    ///   - operation: The async closure to measure.
    /// - Returns: The return value of the closure.
    @discardableResult
    public func measureAsync<T>(_ label: String, operation: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        logDuration(label: label, elapsed: elapsed)
        return result
    }

    // MARK: - Manual Start/Stop

    /// Starts a manual measurement.
    ///
    /// - Parameter label: A descriptive label for the operation.
    /// - Returns: A token to pass to ``stop(_:)`` when the operation completes.
    public func start(_ label: String) -> MeasurementToken {
        let token = MeasurementToken(
            label: label,
            startTime: CFAbsoluteTimeGetCurrent(),
            id: UUID()
        )
        queue.sync {
            activeMeasurements[token.id] = token
        }
        return token
    }

    /// Stops a manual measurement and logs the elapsed time.
    ///
    /// - Parameter token: The token returned by ``start(_:)``.
    /// - Returns: The elapsed time in seconds, or `nil` if the token was invalid.
    @discardableResult
    public func stop(_ token: MeasurementToken) -> TimeInterval? {
        let elapsed = CFAbsoluteTimeGetCurrent() - token.startTime

        _ = queue.sync {
            activeMeasurements.removeValue(forKey: token.id)
        }

        logDuration(label: token.label, elapsed: elapsed)
        return elapsed
    }

    // MARK: - Private

    /// Logs the measured duration.
    private func logDuration(label: String, elapsed: TimeInterval) {
        let ms = elapsed * 1000
        let formatted = String(format: "%.2f ms", ms)

        logger.log(
            level: logLevel,
            message: "⏱ [\(label)] completed in \(formatted)",
            metadata: [
                "operation": label,
                "duration_ms": String(format: "%.2f", ms)
            ]
        )
    }
}
