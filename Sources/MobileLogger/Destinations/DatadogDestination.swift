import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Datadog Configuration

/// Configuration for Datadog log ingestion endpoint.
///
/// Supports both US and EU Datadog regions with automatic endpoint selection.
/// Includes all standard Datadog logging configuration options.
public struct DatadogConfiguration: Sendable {
    
    // MARK: - Region
    
    /// Datadog datacenter region.
    public enum Region: String, Sendable, CaseIterable {
        /// US1 datacenter (default)
        case us1 = "datadoghq.com"
        /// US3 datacenter
        case us3 = "us3.datadoghq.com"
        /// US5 datacenter
        case us5 = "us5.datadoghq.com"
        /// EU1 datacenter
        case eu1 = "datadoghq.eu"
        /// AP1 datacenter (Asia Pacific)
        case ap1 = "ap1.datadoghq.com"
        /// US1-FED datacenter (Government)
        case gov = "ddog-gov.com"
        
        /// The logs intake endpoint URL for this region.
        public var logsEndpoint: URL {
            URL(string: "https://http-intake.logs.\(rawValue)/api/v2/logs")!
        }
        
        /// The metrics intake endpoint URL for this region.
        public var metricsEndpoint: URL {
            URL(string: "https://api.\(rawValue)/api/v2/series")!
        }
    }
    
    // MARK: - Properties
    
    /// Datadog API key for authentication.
    public let apiKey: String
    
    /// Optional application key for extended API access.
    public let applicationKey: String?
    
    /// Datacenter region.
    public let region: Region
    
    /// Service name identifier.
    public let serviceName: String
    
    /// Environment tag (e.g., production, staging).
    public let environment: String
    
    /// Application version string.
    public let version: String
    
    /// Source identifier for logs.
    public let source: String
    
    /// Custom hostname override.
    public let hostname: String?
    
    /// Additional global tags applied to all logs.
    public let globalTags: [String: String]
    
    /// Maximum batch size before forced flush.
    public let maxBatchSize: Int
    
    /// Maximum time interval between flushes.
    public let flushInterval: TimeInterval
    
    /// Enable automatic network tracking.
    public let trackNetworkRequests: Bool
    
    /// Enable automatic error tracking.
    public let trackErrors: Bool
    
    /// Enable user action tracking.
    public let trackUserActions: Bool
    
    /// Sample rate for logs (0.0 to 1.0).
    public let sampleRate: Double
    
    /// Enable debug mode for verbose output.
    public let debugMode: Bool
    
    // MARK: - Initialization
    
    /// Creates a new Datadog configuration.
    ///
    /// - Parameters:
    ///   - apiKey: Your Datadog API key.
    ///   - applicationKey: Optional application key.
    ///   - region: Datacenter region (default: US1).
    ///   - serviceName: Service identifier.
    ///   - environment: Environment tag.
    ///   - version: App version.
    ///   - source: Log source identifier.
    ///   - hostname: Custom hostname.
    ///   - globalTags: Additional global tags.
    ///   - maxBatchSize: Maximum logs per batch (default: 100).
    ///   - flushInterval: Flush interval in seconds (default: 30).
    ///   - trackNetworkRequests: Enable network tracking.
    ///   - trackErrors: Enable error tracking.
    ///   - trackUserActions: Enable user action tracking.
    ///   - sampleRate: Log sample rate (default: 1.0).
    ///   - debugMode: Enable debug output.
    public init(
        apiKey: String,
        applicationKey: String? = nil,
        region: Region = .us1,
        serviceName: String,
        environment: String = "production",
        version: String = "1.0.0",
        source: String = "ios",
        hostname: String? = nil,
        globalTags: [String: String] = [:],
        maxBatchSize: Int = 100,
        flushInterval: TimeInterval = 30,
        trackNetworkRequests: Bool = true,
        trackErrors: Bool = true,
        trackUserActions: Bool = false,
        sampleRate: Double = 1.0,
        debugMode: Bool = false
    ) {
        self.apiKey = apiKey
        self.applicationKey = applicationKey
        self.region = region
        self.serviceName = serviceName
        self.environment = environment
        self.version = version
        self.source = source
        self.hostname = hostname
        self.globalTags = globalTags
        self.maxBatchSize = maxBatchSize
        self.flushInterval = flushInterval
        self.trackNetworkRequests = trackNetworkRequests
        self.trackErrors = trackErrors
        self.trackUserActions = trackUserActions
        self.sampleRate = min(1.0, max(0.0, sampleRate))
        self.debugMode = debugMode
    }
}

// MARK: - Datadog Log Format

/// Internal representation of a Datadog-formatted log entry.
private struct DatadogLog: Codable {
    let message: String
    let status: String
    let service: String
    let ddsource: String
    let ddtags: String
    let hostname: String
    let date: Int64
    let logger: DatadogLogger
    let usr: DatadogUser?
    let device: DatadogDevice
    let os: DatadogOS
    let application: DatadogApplication
    let session: DatadogSession?
    let view: DatadogView?
    let error: DatadogError?
    let network: DatadogNetwork?
    let custom: [String: AnyCodable]?
    
    struct DatadogLogger: Codable {
        let name: String
        let version: String
        let threadName: String?
    }
    
    struct DatadogUser: Codable {
        let id: String?
        let name: String?
        let email: String?
        let extraInfo: [String: String]?
        
        enum CodingKeys: String, CodingKey {
            case id, name, email
            case extraInfo = "extra_info"
        }
    }
    
    struct DatadogDevice: Codable {
        let type: String
        let brand: String
        let model: String
        let name: String
        let architecture: String?
    }
    
    struct DatadogOS: Codable {
        let name: String
        let version: String
        let build: String?
    }
    
    struct DatadogApplication: Codable {
        let id: String
        let name: String
        let version: String
        let buildNumber: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name, version
            case buildNumber = "build_number"
        }
    }
    
    struct DatadogSession: Codable {
        let id: String
        let type: String
    }
    
    struct DatadogView: Codable {
        let id: String?
        let name: String?
        let url: String?
    }
    
    struct DatadogError: Codable {
        let kind: String?
        let message: String?
        let stack: String?
        let sourceType: String?
        let fingerprint: String?
        
        enum CodingKeys: String, CodingKey {
            case kind, message, stack
            case sourceType = "source_type"
            case fingerprint
        }
    }
    
    struct DatadogNetwork: Codable {
        let client: NetworkClient?
        
        struct NetworkClient: Codable {
            let simCarrier: SimCarrier?
            let connectivity: String?
            let reachability: String?
            
            enum CodingKeys: String, CodingKey {
                case simCarrier = "sim_carrier"
                case connectivity, reachability
            }
            
            struct SimCarrier: Codable {
                let name: String?
                let isoCountry: String?
                let technology: String?
                
                enum CodingKeys: String, CodingKey {
                    case name
                    case isoCountry = "iso_country"
                    case technology
                }
            }
        }
    }
}

// MARK: - Any Codable Wrapper

/// Type-erased Codable wrapper for dynamic JSON values.
private struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Datadog Destination

/// A log destination that sends entries to Datadog's log management platform.
///
/// This destination provides full integration with Datadog's logging infrastructure,
/// including automatic batching, retry logic, and comprehensive device/context tracking.
///
/// ## Features
///
/// - Automatic batching with configurable size and interval
/// - Exponential backoff retry for failed requests
/// - Offline buffering with persistence
/// - Automatic device, OS, and app context enrichment
/// - User session tracking
/// - Network state monitoring
/// - Error stack trace capturing
///
/// ## Usage
///
/// ```swift
/// let config = DatadogConfiguration(
///     apiKey: "your-api-key",
///     serviceName: "my-ios-app",
///     environment: "production"
/// )
/// let destination = DatadogDestination(configuration: config)
/// Logger.shared.addDestination(destination)
/// ```
public final class DatadogDestination: LogDestination, @unchecked Sendable {
    
    // MARK: - LogDestination Conformance
    
    public var minimumLevel: LogLevel
    public var formatter: LogFormatter
    
    // MARK: - Properties
    
    /// The Datadog configuration.
    public let configuration: DatadogConfiguration
    
    /// Current user information for log enrichment.
    public private(set) var currentUser: UserInfo?
    
    /// Current session identifier.
    public private(set) var sessionId: String
    
    /// Current view information.
    public private(set) var currentView: ViewInfo?
    
    // MARK: - Private Properties
    
    private let queue: DispatchQueue
    private let urlSession: URLSession
    private var pendingLogs: [DatadogLog] = []
    private var flushTimer: DispatchSourceTimer?
    private var retryCount: Int = 0
    private let maxRetries: Int = 5
    private let persistenceURL: URL?
    private var isFlushInProgress: Bool = false
    private let deviceInfo: DeviceInfo
    private let appInfo: AppInfo
    
    // MARK: - Nested Types
    
    /// User information for log enrichment.
    public struct UserInfo: Sendable {
        public let id: String?
        public let name: String?
        public let email: String?
        public let extraInfo: [String: String]
        
        public init(
            id: String? = nil,
            name: String? = nil,
            email: String? = nil,
            extraInfo: [String: String] = [:]
        ) {
            self.id = id
            self.name = name
            self.email = email
            self.extraInfo = extraInfo
        }
    }
    
    /// View information for log context.
    public struct ViewInfo: Sendable {
        public let id: String
        public let name: String
        public let url: String?
        
        public init(id: String, name: String, url: String? = nil) {
            self.id = id
            self.name = name
            self.url = url
        }
    }
    
    /// Cached device information.
    private struct DeviceInfo {
        let type: String
        let brand: String
        let model: String
        let name: String
        let architecture: String?
        
        static func current() -> DeviceInfo {
            #if canImport(UIKit) && !os(watchOS)
            let device = UIDevice.current
            return DeviceInfo(
                type: device.userInterfaceIdiom == .phone ? "mobile" : "tablet",
                brand: "Apple",
                model: Self.modelIdentifier(),
                name: device.name,
                architecture: Self.cpuArchitecture()
            )
            #else
            return DeviceInfo(
                type: "desktop",
                brand: "Apple",
                model: "Mac",
                name: Host.current().localizedName ?? "Unknown",
                architecture: Self.cpuArchitecture()
            )
            #endif
        }
        
        private static func modelIdentifier() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
        
        private static func cpuArchitecture() -> String? {
            #if arch(arm64)
            return "arm64"
            #elseif arch(x86_64)
            return "x86_64"
            #else
            return nil
            #endif
        }
    }
    
    /// Cached application information.
    private struct AppInfo {
        let id: String
        let name: String
        let version: String
        let buildNumber: String?
        
        static func current() -> AppInfo {
            let bundle = Bundle.main
            return AppInfo(
                id: bundle.bundleIdentifier ?? "unknown",
                name: bundle.infoDictionary?["CFBundleName"] as? String ?? "Unknown",
                version: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0",
                buildNumber: bundle.infoDictionary?["CFBundleVersion"] as? String
            )
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a new Datadog destination.
    ///
    /// - Parameters:
    ///   - configuration: Datadog configuration settings.
    ///   - minimumLevel: Minimum log level to process.
    ///   - formatter: Log formatter (default: JSONFormatter).
    public init(
        configuration: DatadogConfiguration,
        minimumLevel: LogLevel = .debug,
        formatter: LogFormatter = JSONFormatter()
    ) {
        self.configuration = configuration
        self.minimumLevel = minimumLevel
        self.formatter = formatter
        self.sessionId = UUID().uuidString
        self.deviceInfo = DeviceInfo.current()
        self.appInfo = AppInfo.current()
        
        self.queue = DispatchQueue(
            label: "com.mobilelogger.datadog",
            qos: .utility
        )
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "DD-API-KEY": configuration.apiKey
        ]
        if let appKey = configuration.applicationKey {
            sessionConfig.httpAdditionalHeaders?["DD-APPLICATION-KEY"] = appKey
        }
        self.urlSession = URLSession(configuration: sessionConfig)
        
        // Setup persistence
        if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.persistenceURL = cachesDir.appendingPathComponent("datadog_logs_buffer.json")
            loadPersistedLogs()
        } else {
            self.persistenceURL = nil
        }
        
        startFlushTimer()
        setupAppLifecycleObservers()
    }
    
    deinit {
        flushTimer?.cancel()
        flush(sync: true)
    }
    
    // MARK: - LogDestination
    
    public func send(_ entry: LogEntry) {
        guard configuration.sampleRate >= 1.0 || Double.random(in: 0...1) < configuration.sampleRate else {
            return
        }
        
        let datadogLog = createDatadogLog(from: entry)
        
        queue.async { [weak self] in
            self?.pendingLogs.append(datadogLog)
            
            if let maxBatch = self?.configuration.maxBatchSize,
               let count = self?.pendingLogs.count,
               count >= maxBatch {
                self?.flush(sync: false)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the current user information for log enrichment.
    ///
    /// - Parameter user: User information or nil to clear.
    public func setUser(_ user: UserInfo?) {
        queue.async { [weak self] in
            self?.currentUser = user
        }
    }
    
    /// Starts a new session with a fresh session ID.
    ///
    /// - Returns: The new session ID.
    @discardableResult
    public func startNewSession() -> String {
        let newSessionId = UUID().uuidString
        queue.async { [weak self] in
            self?.sessionId = newSessionId
        }
        return newSessionId
    }
    
    /// Updates the current view context.
    ///
    /// - Parameter view: View information or nil to clear.
    public func setCurrentView(_ view: ViewInfo?) {
        queue.async { [weak self] in
            self?.currentView = view
        }
    }
    
    /// Forces an immediate flush of pending logs.
    ///
    /// - Parameter sync: If true, blocks until flush completes.
    public func flush(sync: Bool = false) {
        let flushWork = { [weak self] in
            self?.performFlush()
        }
        
        if sync {
            queue.sync(execute: flushWork)
        } else {
            queue.async(execute: flushWork)
        }
    }
    
    /// Returns the count of pending logs awaiting transmission.
    public var pendingLogCount: Int {
        queue.sync { pendingLogs.count }
    }
    
    // MARK: - Private Methods
    
    private func createDatadogLog(from entry: LogEntry) -> DatadogLog {
        let status = mapLogLevel(entry.level)
        let tags = buildTags(from: entry)
        
        var errorInfo: DatadogLog.DatadogError? = nil
        if entry.level >= .error {
            errorInfo = DatadogLog.DatadogError(
                kind: entry.metadata?["error.kind"],
                message: entry.metadata?["error.message"] ?? entry.message,
                stack: entry.metadata?["error.stack"],
                sourceType: "ios",
                fingerprint: entry.metadata?["error.fingerprint"]
            )
        }
        
        let userInfo: DatadogLog.DatadogUser?
        if let user = currentUser {
            userInfo = DatadogLog.DatadogUser(
                id: user.id,
                name: user.name,
                email: user.email,
                extraInfo: user.extraInfo.isEmpty ? nil : user.extraInfo
            )
        } else {
            userInfo = nil
        }
        
        let viewInfo: DatadogLog.DatadogView?
        if let view = currentView {
            viewInfo = DatadogLog.DatadogView(
                id: view.id,
                name: view.name,
                url: view.url
            )
        } else {
            viewInfo = nil
        }
        
        var customAttributes: [String: AnyCodable]? = nil
        if let metadata = entry.metadata {
            var filtered = metadata
            // Remove standard fields
            filtered.removeValue(forKey: "error.kind")
            filtered.removeValue(forKey: "error.message")
            filtered.removeValue(forKey: "error.stack")
            filtered.removeValue(forKey: "error.fingerprint")
            
            if !filtered.isEmpty {
                customAttributes = filtered.mapValues { AnyCodable($0) }
            }
        }
        
        return DatadogLog(
            message: entry.message,
            status: status,
            service: configuration.serviceName,
            ddsource: configuration.source,
            ddtags: tags,
            hostname: configuration.hostname ?? deviceInfo.name,
            date: Int64(entry.timestamp.timeIntervalSince1970 * 1000),
            logger: DatadogLog.DatadogLogger(
                name: "MobileLogger",
                version: "1.0.0",
                threadName: Thread.isMainThread ? "main" : "background"
            ),
            usr: userInfo,
            device: DatadogLog.DatadogDevice(
                type: deviceInfo.type,
                brand: deviceInfo.brand,
                model: deviceInfo.model,
                name: deviceInfo.name,
                architecture: deviceInfo.architecture
            ),
            os: DatadogLog.DatadogOS(
                name: osName(),
                version: osVersion(),
                build: nil
            ),
            application: DatadogLog.DatadogApplication(
                id: appInfo.id,
                name: appInfo.name,
                version: appInfo.version,
                buildNumber: appInfo.buildNumber
            ),
            session: DatadogLog.DatadogSession(
                id: sessionId,
                type: "user"
            ),
            view: viewInfo,
            error: errorInfo,
            network: nil,
            custom: customAttributes
        )
    }
    
    private func mapLogLevel(_ level: LogLevel) -> String {
        switch level {
        case .trace:
            return "trace"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .warning:
            return "warn"
        case .error:
            return "error"
        case .critical:
            return "critical"
        }
    }
    
    private func buildTags(from entry: LogEntry) -> String {
        var tags: [String] = []
        
        // Add environment
        tags.append("env:\(configuration.environment)")
        
        // Add version
        tags.append("version:\(configuration.version)")
        
        // Add global tags
        for (key, value) in configuration.globalTags {
            tags.append("\(key):\(value)")
        }
        
        // Add source file info
        let fileName = (entry.file as NSString).lastPathComponent
        tags.append("source_file:\(fileName)")
        tags.append("line:\(entry.line)")
        
        return tags.joined(separator: ",")
    }
    
    private func osName() -> String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
    
    private func osVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    private func startFlushTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(
            deadline: .now() + configuration.flushInterval,
            repeating: configuration.flushInterval
        )
        timer.setEventHandler { [weak self] in
            self?.performFlush()
        }
        timer.resume()
        flushTimer = timer
    }
    
    private func performFlush() {
        guard !pendingLogs.isEmpty, !isFlushInProgress else { return }
        
        isFlushInProgress = true
        let logsToSend = pendingLogs
        pendingLogs.removeAll()
        
        sendLogs(logsToSend) { [weak self] success in
            self?.queue.async {
                self?.isFlushInProgress = false
                
                if !success {
                    // Re-add failed logs to pending
                    self?.pendingLogs.insert(contentsOf: logsToSend, at: 0)
                    self?.persistPendingLogs()
                    self?.scheduleRetry()
                } else {
                    self?.retryCount = 0
                }
            }
        }
    }
    
    private func sendLogs(_ logs: [DatadogLog], completion: @escaping (Bool) -> Void) {
        guard !logs.isEmpty else {
            completion(true)
            return
        }
        
        let endpoint = configuration.region.logsEndpoint
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            request.httpBody = try encoder.encode(logs)
        } catch {
            if configuration.debugMode {
                print("[Datadog] Failed to encode logs: \(error)")
            }
            completion(false)
            return
        }
        
        if configuration.debugMode {
            print("[Datadog] Sending \(logs.count) logs to \(endpoint)")
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                if self?.configuration.debugMode == true {
                    print("[Datadog] Network error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            let success = (200..<300).contains(httpResponse.statusCode)
            
            if self?.configuration.debugMode == true {
                if success {
                    print("[Datadog] Successfully sent \(logs.count) logs")
                } else {
                    print("[Datadog] Server error: \(httpResponse.statusCode)")
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("[Datadog] Response: \(body)")
                    }
                }
            }
            
            completion(success)
        }
        task.resume()
    }
    
    private func scheduleRetry() {
        guard retryCount < maxRetries else {
            if configuration.debugMode {
                print("[Datadog] Max retries reached, dropping logs")
            }
            pendingLogs.removeAll()
            retryCount = 0
            return
        }
        
        retryCount += 1
        let delay = pow(2.0, Double(retryCount)) // Exponential backoff
        
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.performFlush()
        }
    }
    
    private func persistPendingLogs() {
        guard let url = persistenceURL else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pendingLogs)
            try data.write(to: url)
        } catch {
            if configuration.debugMode {
                print("[Datadog] Failed to persist logs: \(error)")
            }
        }
    }
    
    private func loadPersistedLogs() {
        guard let url = persistenceURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let logs = try decoder.decode([DatadogLog].self, from: data)
            pendingLogs = logs
            try FileManager.default.removeItem(at: url)
            
            if configuration.debugMode {
                print("[Datadog] Loaded \(logs.count) persisted logs")
            }
        } catch {
            if configuration.debugMode {
                print("[Datadog] Failed to load persisted logs: \(error)")
            }
        }
    }
    
    private func setupAppLifecycleObservers() {
        #if canImport(UIKit) && !os(watchOS)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.flush(sync: true)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.flush(sync: true)
        }
        #endif
    }
}

// MARK: - Datadog RUM Integration

/// Extension for Real User Monitoring integration.
extension DatadogDestination {
    
    /// Tracks a user action event.
    ///
    /// - Parameters:
    ///   - type: The action type (tap, scroll, swipe, etc.).
    ///   - name: Human-readable action name.
    ///   - attributes: Additional attributes.
    public func trackUserAction(
        type: UserActionType,
        name: String,
        attributes: [String: String] = [:]
    ) {
        guard configuration.trackUserActions else { return }
        
        var metadata = attributes
        metadata["action.type"] = type.rawValue
        metadata["action.name"] = name
        
        let entry = LogEntry(
            level: .info,
            message: "User action: \(name)",
            metadata: metadata,
            file: #file,
            function: #function,
            line: #line
        )
        
        send(entry)
    }
    
    /// User action types for RUM tracking.
    public enum UserActionType: String, Sendable {
        case tap
        case scroll
        case swipe
        case click
        case custom
    }
    
    /// Tracks a resource loading event.
    ///
    /// - Parameters:
    ///   - url: The resource URL.
    ///   - method: HTTP method.
    ///   - statusCode: Response status code.
    ///   - duration: Loading duration in milliseconds.
    ///   - size: Response size in bytes.
    public func trackResource(
        url: URL,
        method: String,
        statusCode: Int,
        duration: TimeInterval,
        size: Int64? = nil
    ) {
        guard configuration.trackNetworkRequests else { return }
        
        var metadata: [String: String] = [
            "resource.url": url.absoluteString,
            "resource.method": method,
            "resource.status_code": "\(statusCode)",
            "resource.duration": "\(Int(duration * 1000))ms"
        ]
        
        if let size = size {
            metadata["resource.size"] = "\(size)"
        }
        
        let entry = LogEntry(
            level: statusCode >= 400 ? .warning : .debug,
            message: "Resource: \(method) \(url.path) -> \(statusCode)",
            metadata: metadata,
            file: #file,
            function: #function,
            line: #line
        )
        
        send(entry)
    }
    
    /// Tracks an error with full context.
    ///
    /// - Parameters:
    ///   - error: The error to track.
    ///   - source: Error source (network, custom, etc.).
    ///   - attributes: Additional attributes.
    public func trackError(
        _ error: Error,
        source: ErrorSource = .custom,
        attributes: [String: String] = [:]
    ) {
        guard configuration.trackErrors else { return }
        
        var metadata = attributes
        metadata["error.kind"] = String(describing: type(of: error))
        metadata["error.message"] = error.localizedDescription
        metadata["error.source"] = source.rawValue
        
        if let nsError = error as NSError? {
            metadata["error.domain"] = nsError.domain
            metadata["error.code"] = "\(nsError.code)"
        }
        
        // Capture stack trace
        let symbols = Thread.callStackSymbols.joined(separator: "\n")
        metadata["error.stack"] = symbols
        
        let entry = LogEntry(
            level: .error,
            message: "Error: \(error.localizedDescription)",
            metadata: metadata,
            file: #file,
            function: #function,
            line: #line
        )
        
        send(entry)
    }
    
    /// Error source types.
    public enum ErrorSource: String, Sendable {
        case network
        case source
        case console
        case logger
        case agent
        case webview
        case custom
    }
}
