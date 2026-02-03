import Foundation

// MARK: - AnalyticsProvider

/// A protocol for analytics service integration.
///
/// Implement this protocol to send log data to your analytics platform.
///
/// ```swift
/// class MyAnalytics: AnalyticsProvider {
///     func track(_ event: AnalyticsEvent) {
///         // Send to your analytics service
///     }
/// }
/// ```
public protocol AnalyticsProvider: Sendable {

    /// The unique identifier for this analytics provider.
    var providerId: String { get }

    /// Whether the provider is currently enabled.
    var isEnabled: Bool { get }

    /// Tracks an analytics event.
    ///
    /// - Parameter event: The event to track.
    func track(_ event: AnalyticsEvent)

    /// Tracks a batch of analytics events.
    ///
    /// - Parameter events: The events to track.
    func trackBatch(_ events: [AnalyticsEvent])

    /// Flushes any pending events to the backend.
    func flush()

    /// Sets user properties for analytics.
    ///
    /// - Parameter properties: Key-value pairs of user properties.
    func setUserProperties(_ properties: [String: Any])

    /// Resets the analytics state (e.g., on user logout).
    func reset()
}

// MARK: - Default Implementation

extension AnalyticsProvider {

    public func trackBatch(_ events: [AnalyticsEvent]) {
        for event in events {
            track(event)
        }
    }

    public func setUserProperties(_ properties: [String: Any]) {
        // Default no-op
    }

    public func reset() {
        // Default no-op
    }
}

// MARK: - AnalyticsEvent

/// An analytics event derived from log entries.
///
/// Events capture structured data about application behavior
/// suitable for analytics platforms.
public struct AnalyticsEvent: Sendable, Codable, Identifiable {

    /// Unique identifier for the event.
    public let id: UUID

    /// The event name/type.
    public let name: String

    /// When the event occurred.
    public let timestamp: Date

    /// The log level that triggered this event.
    public let level: LogLevel

    /// The original log message.
    public let message: String

    /// Structured properties associated with the event.
    public var properties: [String: String]

    /// The category or subsystem for the event.
    public var category: String?

    /// Session identifier for grouping events.
    public var sessionId: String?

    /// User identifier for attribution.
    public var userId: String?

    /// Device information.
    public var deviceInfo: DeviceInfo?

    // MARK: - Initialization

    /// Creates a new analytics event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - level: The log level.
    ///   - message: The log message.
    ///   - properties: Event properties.
    ///   - category: Event category.
    public init(
        name: String,
        level: LogLevel,
        message: String,
        properties: [String: String] = [:],
        category: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.level = level
        self.message = message
        self.properties = properties
        self.category = category
        self.sessionId = nil
        self.userId = nil
        self.deviceInfo = nil
    }

    /// Creates an analytics event from a log entry.
    ///
    /// - Parameters:
    ///   - entry: The source log entry.
    ///   - eventName: Optional custom event name.
    public init(from entry: LogEntry, eventName: String? = nil) {
        self.id = entry.id
        self.name = eventName ?? "log_\(entry.level.description)"
        self.timestamp = entry.timestamp
        self.level = entry.level
        self.message = entry.message
        self.properties = entry.metadata ?? [:]
        self.category = nil
        self.sessionId = nil
        self.userId = nil
        self.deviceInfo = nil
    }
}

// MARK: - DeviceInfo

/// Device information for analytics context.
public struct DeviceInfo: Sendable, Codable {

    /// The device model (e.g., "iPhone 14 Pro").
    public let model: String

    /// The operating system name.
    public let osName: String

    /// The operating system version.
    public let osVersion: String

    /// The app version string.
    public let appVersion: String

    /// The app build number.
    public let buildNumber: String

    /// The device locale identifier.
    public let locale: String

    /// The device timezone identifier.
    public let timezone: String

    /// Whether the device is a simulator.
    public let isSimulator: Bool

    /// Screen dimensions.
    public let screenSize: String

    // MARK: - Initialization

    /// Creates device info with the current device's details.
    public static func current() -> DeviceInfo {
        #if os(iOS)
        import UIKit
        let device = UIDevice.current
        let screen = UIScreen.main.bounds
        return DeviceInfo(
            model: device.model,
            osName: device.systemName,
            osVersion: device.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier,
            isSimulator: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil,
            screenSize: "\(Int(screen.width))x\(Int(screen.height))"
        )
        #else
        return DeviceInfo(
            model: "Mac",
            osName: "macOS",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier,
            isSimulator: false,
            screenSize: "unknown"
        )
        #endif
    }

    /// Creates device info with custom values.
    public init(
        model: String,
        osName: String,
        osVersion: String,
        appVersion: String,
        buildNumber: String,
        locale: String,
        timezone: String,
        isSimulator: Bool,
        screenSize: String
    ) {
        self.model = model
        self.osName = osName
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.locale = locale
        self.timezone = timezone
        self.isSimulator = isSimulator
        self.screenSize = screenSize
    }
}

// MARK: - AnalyticsConfiguration

/// Configuration options for analytics integration.
public struct AnalyticsConfiguration: Sendable {

    /// Whether analytics is enabled.
    public var isEnabled: Bool

    /// Minimum log level to track as events.
    public var minimumLevel: LogLevel

    /// Whether to include device information.
    public var includeDeviceInfo: Bool

    /// Whether to include source location.
    public var includeSourceLocation: Bool

    /// Maximum events to batch before sending.
    public var batchSize: Int

    /// Interval in seconds between batch flushes.
    public var flushInterval: TimeInterval

    /// Event categories to track (empty means all).
    public var includedCategories: Set<String>

    /// Event categories to exclude.
    public var excludedCategories: Set<String>

    /// Sampling rate (0.0 to 1.0).
    public var samplingRate: Double

    /// Whether to track user sessions.
    public var trackSessions: Bool

    /// Session timeout in seconds.
    public var sessionTimeout: TimeInterval

    // MARK: - Defaults

    /// Default analytics configuration.
    public static var `default`: AnalyticsConfiguration {
        AnalyticsConfiguration(
            isEnabled: true,
            minimumLevel: .warning,
            includeDeviceInfo: true,
            includeSourceLocation: true,
            batchSize: 50,
            flushInterval: 60,
            includedCategories: [],
            excludedCategories: [],
            samplingRate: 1.0,
            trackSessions: true,
            sessionTimeout: 1800
        )
    }

    /// Configuration for minimal analytics footprint.
    public static var minimal: AnalyticsConfiguration {
        AnalyticsConfiguration(
            isEnabled: true,
            minimumLevel: .error,
            includeDeviceInfo: false,
            includeSourceLocation: false,
            batchSize: 100,
            flushInterval: 300,
            includedCategories: [],
            excludedCategories: [],
            samplingRate: 0.5,
            trackSessions: false,
            sessionTimeout: 0
        )
    }
}

// MARK: - AnalyticsManager

/// Manages analytics providers and event dispatch.
///
/// The analytics manager coordinates between log entries and
/// registered analytics providers.
///
/// ```swift
/// let manager = AnalyticsManager.shared
/// manager.register(FirebaseAnalytics())
/// manager.register(MixpanelAnalytics())
///
/// // Events are automatically dispatched to all providers
/// manager.track(event)
/// ```
public final class AnalyticsManager: @unchecked Sendable {

    // MARK: - Shared Instance

    /// The shared analytics manager instance.
    public static let shared = AnalyticsManager()

    // MARK: - Properties

    /// Configuration for analytics behavior.
    public var configuration: AnalyticsConfiguration

    /// The current user identifier.
    public var userId: String?

    /// The current session identifier.
    public private(set) var sessionId: String?

    /// User properties to include with events.
    public var userProperties: [String: Any] = [:]

    // MARK: - Private

    /// Serial queue for thread-safe operations.
    private let queue = DispatchQueue(label: "com.mobilelogger.analytics", qos: .utility)

    /// Registered analytics providers.
    private var providers: [AnalyticsProvider] = []

    /// Pending events waiting to be flushed.
    private var pendingEvents: [AnalyticsEvent] = []

    /// Timer for periodic flush.
    private var flushTimer: DispatchSourceTimer?

    /// Last activity timestamp for session tracking.
    private var lastActivityTime: Date = Date()

    /// Random number generator for sampling.
    private var randomGenerator = SystemRandomNumberGenerator()

    // MARK: - Initialization

    /// Creates a new analytics manager.
    ///
    /// - Parameter configuration: Analytics configuration.
    public init(configuration: AnalyticsConfiguration = .default) {
        self.configuration = configuration
        if configuration.trackSessions {
            startNewSession()
        }
    }

    deinit {
        stopFlushTimer()
    }

    // MARK: - Provider Management

    /// Registers an analytics provider.
    ///
    /// - Parameter provider: The provider to register.
    public func register(_ provider: AnalyticsProvider) {
        queue.async { [weak self] in
            self?.providers.append(provider)
        }
    }

    /// Unregisters an analytics provider.
    ///
    /// - Parameter providerId: The ID of the provider to remove.
    public func unregister(providerId: String) {
        queue.async { [weak self] in
            self?.providers.removeAll { $0.providerId == providerId }
        }
    }

    /// Returns all registered provider IDs.
    public var registeredProviders: [String] {
        queue.sync { providers.map { $0.providerId } }
    }

    // MARK: - Event Tracking

    /// Tracks an analytics event.
    ///
    /// - Parameter event: The event to track.
    public func track(_ event: AnalyticsEvent) {
        guard configuration.isEnabled else { return }
        guard event.level >= configuration.minimumLevel else { return }
        guard shouldSampleEvent() else { return }
        guard shouldTrackCategory(event.category) else { return }

        queue.async { [weak self] in
            guard let self else { return }

            var enrichedEvent = event
            enrichedEvent.sessionId = self.sessionId
            enrichedEvent.userId = self.userId

            if self.configuration.includeDeviceInfo {
                enrichedEvent.deviceInfo = DeviceInfo.current()
            }

            self.pendingEvents.append(enrichedEvent)

            if self.pendingEvents.count >= self.configuration.batchSize {
                self.flushEvents()
            }

            self.updateSessionActivity()
        }
    }

    /// Tracks a log entry as an analytics event.
    ///
    /// - Parameters:
    ///   - entry: The log entry to track.
    ///   - eventName: Optional custom event name.
    public func track(entry: LogEntry, eventName: String? = nil) {
        let event = AnalyticsEvent(from: entry, eventName: eventName)
        track(event)
    }

    /// Tracks a custom event with properties.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - properties: Event properties.
    ///   - level: The log level.
    public func track(
        name: String,
        properties: [String: String] = [:],
        level: LogLevel = .info
    ) {
        let event = AnalyticsEvent(
            name: name,
            level: level,
            message: name,
            properties: properties
        )
        track(event)
    }

    // MARK: - Flush

    /// Flushes all pending events to registered providers.
    public func flush() {
        queue.async { [weak self] in
            self?.flushEvents()
        }
    }

    /// Starts the periodic flush timer.
    public func startPeriodicFlush() {
        queue.async { [weak self] in
            self?.startFlushTimer()
        }
    }

    /// Stops the periodic flush timer.
    public func stopPeriodicFlush() {
        queue.async { [weak self] in
            self?.stopFlushTimer()
        }
    }

    // MARK: - Session Management

    /// Starts a new analytics session.
    public func startNewSession() {
        queue.async { [weak self] in
            self?.sessionId = UUID().uuidString
            self?.lastActivityTime = Date()
        }
    }

    /// Ends the current session.
    public func endSession() {
        queue.async { [weak self] in
            self?.flushEvents()
            self?.sessionId = nil
        }
    }

    /// Checks if the session has timed out and creates a new one if needed.
    private func updateSessionActivity() {
        guard configuration.trackSessions else { return }

        let now = Date()
        if now.timeIntervalSince(lastActivityTime) > configuration.sessionTimeout {
            sessionId = UUID().uuidString
        }
        lastActivityTime = now
    }

    // MARK: - User Management

    /// Sets the user identifier for analytics attribution.
    ///
    /// - Parameter userId: The user identifier.
    public func setUserId(_ userId: String?) {
        queue.async { [weak self] in
            self?.userId = userId
            self?.providers.forEach { provider in
                if let id = userId {
                    provider.setUserProperties(["user_id": id])
                }
            }
        }
    }

    /// Sets user properties for analytics context.
    ///
    /// - Parameter properties: Key-value pairs of user properties.
    public func setUserProperties(_ properties: [String: Any]) {
        queue.async { [weak self] in
            guard let self else { return }
            for (key, value) in properties {
                self.userProperties[key] = value
            }
            self.providers.forEach { $0.setUserProperties(properties) }
        }
    }

    /// Resets all analytics state (e.g., on user logout).
    public func reset() {
        queue.async { [weak self] in
            guard let self else { return }
            self.userId = nil
            self.sessionId = nil
            self.userProperties = [:]
            self.pendingEvents.removeAll()
            self.providers.forEach { $0.reset() }

            if self.configuration.trackSessions {
                self.sessionId = UUID().uuidString
            }
        }
    }

    // MARK: - Private Methods

    /// Flushes events to all providers.
    private func flushEvents() {
        guard !pendingEvents.isEmpty else { return }

        let eventsToSend = pendingEvents
        pendingEvents.removeAll()

        for provider in providers where provider.isEnabled {
            provider.trackBatch(eventsToSend)
            provider.flush()
        }
    }

    /// Determines if an event should be sampled.
    private func shouldSampleEvent() -> Bool {
        guard configuration.samplingRate < 1.0 else { return true }
        let random = Double.random(in: 0..<1, using: &randomGenerator)
        return random < configuration.samplingRate
    }

    /// Determines if a category should be tracked.
    private func shouldTrackCategory(_ category: String?) -> Bool {
        // If no category filters, allow all
        if configuration.includedCategories.isEmpty && configuration.excludedCategories.isEmpty {
            return true
        }

        guard let category = category else {
            // No category on event, only allow if no inclusion filter
            return configuration.includedCategories.isEmpty
        }

        // Check exclusion first
        if configuration.excludedCategories.contains(category) {
            return false
        }

        // If inclusion filter is set, category must be included
        if !configuration.includedCategories.isEmpty {
            return configuration.includedCategories.contains(category)
        }

        return true
    }

    /// Starts the flush timer.
    private func startFlushTimer() {
        stopFlushTimer()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        let interval = configuration.flushInterval
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.flushEvents()
        }
        timer.resume()
        flushTimer = timer
    }

    /// Stops the flush timer.
    private func stopFlushTimer() {
        flushTimer?.cancel()
        flushTimer = nil
    }
}

// MARK: - AnalyticsDestination

/// A log destination that sends entries to analytics.
///
/// Automatically converts log entries to analytics events and
/// dispatches them through the analytics manager.
///
/// ```swift
/// let destination = AnalyticsDestination(manager: .shared)
/// destination.minimumLevel = .warning
/// logger.addDestination(destination)
/// ```
public final class AnalyticsDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum log level to send to analytics.
    public var minimumLevel: LogLevel = .warning

    /// Formatter (not used for analytics but required by protocol).
    public var formatter: LogFormatter = JSONFormatter()

    // MARK: - Properties

    /// The analytics manager to use.
    public let manager: AnalyticsManager

    /// Event name prefix for log-derived events.
    public var eventNamePrefix: String = "log_"

    /// Whether to include the full message in events.
    public var includeMessage: Bool = true

    /// Additional properties to add to all events.
    public var additionalProperties: [String: String] = [:]

    /// Custom event name generator.
    public var eventNameGenerator: ((LogEntry) -> String)?

    // MARK: - Initialization

    /// Creates a new analytics destination.
    ///
    /// - Parameter manager: The analytics manager to use.
    public init(manager: AnalyticsManager = .shared) {
        self.manager = manager
    }

    // MARK: - LogDestination

    /// Sends a log entry to analytics.
    ///
    /// - Parameter entry: The log entry to track.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        let eventName: String
        if let generator = eventNameGenerator {
            eventName = generator(entry)
        } else {
            eventName = "\(eventNamePrefix)\(entry.level.description)"
        }

        var properties = entry.metadata ?? [:]

        // Add source location if available
        properties["source_file"] = entry.fileName
        properties["source_line"] = String(entry.line)

        // Add additional properties
        for (key, value) in additionalProperties {
            properties[key] = value
        }

        // Add message if configured
        if includeMessage {
            properties["message"] = entry.message
        }

        var event = AnalyticsEvent(
            name: eventName,
            level: entry.level,
            message: entry.message,
            properties: properties
        )
        event.category = "logs"

        manager.track(event)
    }
}

// MARK: - Built-in Analytics Providers

/// A console analytics provider for debugging.
///
/// Prints analytics events to the console for development.
public final class ConsoleAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {

    public let providerId = "console"
    public var isEnabled = true

    /// Whether to use verbose output.
    public var verbose: Bool

    /// Creates a console analytics provider.
    ///
    /// - Parameter verbose: Whether to use verbose output.
    public init(verbose: Bool = false) {
        self.verbose = verbose
    }

    public func track(_ event: AnalyticsEvent) {
        if verbose {
            print("[Analytics] \(event.name): \(event.message) - \(event.properties)")
        } else {
            print("[Analytics] \(event.name)")
        }
    }

    public func flush() {
        // Console doesn't need flushing
    }
}

/// A file-based analytics provider for offline storage.
///
/// Writes analytics events to a file for later processing.
public final class FileAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {

    public let providerId = "file"
    public var isEnabled = true

    /// The file URL for storing events.
    public let fileURL: URL

    /// Serial queue for file operations.
    private let queue = DispatchQueue(label: "com.mobilelogger.analytics.file", qos: .utility)

    /// JSON encoder for events.
    private let encoder = JSONEncoder()

    /// Creates a file analytics provider.
    ///
    /// - Parameter fileURL: Where to store events.
    public init(fileURL: URL) {
        self.fileURL = fileURL
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
    }

    public func track(_ event: AnalyticsEvent) {
        queue.async { [weak self] in
            guard let self else { return }

            do {
                let data = try self.encoder.encode(event)
                let line = String(data: data, encoding: .utf8)! + "\n"

                if let handle = FileHandle(forWritingAtPath: self.fileURL.path) {
                    handle.seekToEndOfFile()
                    handle.write(line.data(using: .utf8)!)
                    try? handle.close()
                } else {
                    try line.write(to: self.fileURL, atomically: true, encoding: .utf8)
                }
            } catch {
                // Silently fail
            }
        }
    }

    public func flush() {
        // File writes are immediate
    }
}

// MARK: - AnalyticsMetrics

/// Tracks metrics about analytics performance.
public struct AnalyticsMetrics: Sendable {

    /// Total events tracked.
    public var totalEvents: Int = 0

    /// Events dropped due to sampling.
    public var droppedBySampling: Int = 0

    /// Events dropped due to level filtering.
    public var droppedByLevel: Int = 0

    /// Events dropped due to category filtering.
    public var droppedByCategory: Int = 0

    /// Total batches sent.
    public var batchesSent: Int = 0

    /// Total flush operations.
    public var flushCount: Int = 0

    /// Last flush timestamp.
    public var lastFlushTime: Date?

    /// Session count.
    public var sessionCount: Int = 0
}

// MARK: - EventFilter

/// A filter for analytics events.
public struct EventFilter: Sendable {

    /// The filter predicate.
    public let predicate: @Sendable (AnalyticsEvent) -> Bool

    /// Creates an event filter.
    ///
    /// - Parameter predicate: The filter predicate.
    public init(predicate: @escaping @Sendable (AnalyticsEvent) -> Bool) {
        self.predicate = predicate
    }

    /// Filter by minimum log level.
    public static func level(_ minimum: LogLevel) -> EventFilter {
        EventFilter { $0.level >= minimum }
    }

    /// Filter by event name pattern.
    public static func name(contains pattern: String) -> EventFilter {
        EventFilter { $0.name.contains(pattern) }
    }

    /// Filter by category.
    public static func category(_ category: String) -> EventFilter {
        EventFilter { $0.category == category }
    }

    /// Combines multiple filters with AND logic.
    public static func all(_ filters: [EventFilter]) -> EventFilter {
        EventFilter { event in
            filters.allSatisfy { $0.predicate(event) }
        }
    }

    /// Combines multiple filters with OR logic.
    public static func any(_ filters: [EventFilter]) -> EventFilter {
        EventFilter { event in
            filters.contains { $0.predicate(event) }
        }
    }
}
