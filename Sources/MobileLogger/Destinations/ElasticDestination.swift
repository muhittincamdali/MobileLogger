import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Elasticsearch Configuration

/// Configuration for Elasticsearch log destination.
///
/// Supports Elasticsearch clusters with authentication, index templates,
/// and bulk ingestion settings.
public struct ElasticsearchConfiguration: Sendable {
    
    // MARK: - Authentication
    
    /// Authentication methods for Elasticsearch.
    public enum Authentication: Sendable {
        /// No authentication
        case none
        /// Basic authentication with username and password
        case basic(username: String, password: String)
        /// API key authentication
        case apiKey(id: String, apiKey: String)
        /// Bearer token authentication
        case bearer(token: String)
        /// Cloud ID authentication (Elastic Cloud)
        case cloudId(cloudId: String, apiKey: String)
    }
    
    // MARK: - Index Strategy
    
    /// Strategy for index naming and rotation.
    public enum IndexStrategy: Sendable {
        /// Single static index name
        case fixed(name: String)
        /// Daily rotating index (logs-2024.01.15)
        case daily(prefix: String)
        /// Weekly rotating index
        case weekly(prefix: String)
        /// Monthly rotating index
        case monthly(prefix: String)
        /// Custom pattern with date format
        case custom(prefix: String, dateFormat: String)
        
        /// Generates the current index name.
        func currentIndexName() -> String {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            
            switch self {
            case .fixed(let name):
                return name
            case .daily(let prefix):
                formatter.dateFormat = "yyyy.MM.dd"
                return "\(prefix)-\(formatter.string(from: Date()))"
            case .weekly(let prefix):
                formatter.dateFormat = "yyyy.ww"
                return "\(prefix)-\(formatter.string(from: Date()))"
            case .monthly(let prefix):
                formatter.dateFormat = "yyyy.MM"
                return "\(prefix)-\(formatter.string(from: Date()))"
            case .custom(let prefix, let dateFormat):
                formatter.dateFormat = dateFormat
                return "\(prefix)-\(formatter.string(from: Date()))"
            }
        }
    }
    
    // MARK: - Properties
    
    /// Elasticsearch cluster URLs (supports multiple nodes for failover).
    public let nodes: [URL]
    
    /// Authentication configuration.
    public let authentication: Authentication
    
    /// Index naming strategy.
    public let indexStrategy: IndexStrategy
    
    /// Document type (deprecated in ES 7+, but kept for compatibility).
    public let documentType: String
    
    /// Pipeline name for ingest processing.
    public let pipeline: String?
    
    /// Maximum documents per bulk request.
    public let maxBatchSize: Int
    
    /// Maximum batch size in bytes.
    public let maxBatchBytes: Int
    
    /// Flush interval in seconds.
    public let flushInterval: TimeInterval
    
    /// Request timeout in seconds.
    public let requestTimeout: TimeInterval
    
    /// Enable gzip compression for requests.
    public let enableCompression: Bool
    
    /// Enable SSL/TLS verification.
    public let verifySSL: Bool
    
    /// Custom SSL certificate data.
    public let customCertificate: Data?
    
    /// Refresh policy after indexing.
    public let refreshPolicy: RefreshPolicy
    
    /// Enable debug logging.
    public let debugMode: Bool
    
    /// Refresh policy options.
    public enum RefreshPolicy: String, Sendable {
        /// Don't refresh (default, best performance)
        case none = "false"
        /// Wait for refresh
        case waitFor = "wait_for"
        /// Immediate refresh (worst performance)
        case immediate = "true"
    }
    
    // MARK: - Initialization
    
    /// Creates a new Elasticsearch configuration.
    ///
    /// - Parameters:
    ///   - nodes: Cluster node URLs.
    ///   - authentication: Auth configuration.
    ///   - indexStrategy: Index naming strategy.
    ///   - documentType: Document type name.
    ///   - pipeline: Optional ingest pipeline.
    ///   - maxBatchSize: Max docs per batch.
    ///   - maxBatchBytes: Max bytes per batch.
    ///   - flushInterval: Flush interval seconds.
    ///   - requestTimeout: Request timeout seconds.
    ///   - enableCompression: Enable gzip.
    ///   - verifySSL: Verify SSL certificates.
    ///   - customCertificate: Custom CA certificate.
    ///   - refreshPolicy: Index refresh policy.
    ///   - debugMode: Enable debug output.
    public init(
        nodes: [URL],
        authentication: Authentication = .none,
        indexStrategy: IndexStrategy = .daily(prefix: "logs"),
        documentType: String = "_doc",
        pipeline: String? = nil,
        maxBatchSize: Int = 500,
        maxBatchBytes: Int = 5_000_000,
        flushInterval: TimeInterval = 15,
        requestTimeout: TimeInterval = 30,
        enableCompression: Bool = true,
        verifySSL: Bool = true,
        customCertificate: Data? = nil,
        refreshPolicy: RefreshPolicy = .none,
        debugMode: Bool = false
    ) {
        self.nodes = nodes
        self.authentication = authentication
        self.indexStrategy = indexStrategy
        self.documentType = documentType
        self.pipeline = pipeline
        self.maxBatchSize = maxBatchSize
        self.maxBatchBytes = maxBatchBytes
        self.flushInterval = flushInterval
        self.requestTimeout = requestTimeout
        self.enableCompression = enableCompression
        self.verifySSL = verifySSL
        self.customCertificate = customCertificate
        self.refreshPolicy = refreshPolicy
        self.debugMode = debugMode
    }
    
    /// Convenience initializer for single node.
    public init(
        url: URL,
        authentication: Authentication = .none,
        indexStrategy: IndexStrategy = .daily(prefix: "logs"),
        debugMode: Bool = false
    ) {
        self.init(
            nodes: [url],
            authentication: authentication,
            indexStrategy: indexStrategy,
            debugMode: debugMode
        )
    }
}

// MARK: - ECS Document

/// Elastic Common Schema (ECS) formatted log document.
///
/// Follows the ECS specification for standardized log format.
private struct ECSDocument: Codable {
    
    // MARK: - Base Fields
    
    let timestamp: String
    let message: String
    let labels: [String: String]?
    let tags: [String]?
    
    // MARK: - Log Fields
    
    let log: LogFields
    
    struct LogFields: Codable {
        let level: String
        let logger: String
        let origin: LogOrigin?
        
        struct LogOrigin: Codable {
            let file: FileInfo?
            let function: String?
            
            struct FileInfo: Codable {
                let name: String
                let line: Int
            }
        }
    }
    
    // MARK: - Event Fields
    
    let event: EventFields?
    
    struct EventFields: Codable {
        let kind: String
        let category: [String]?
        let type: [String]?
        let outcome: String?
        let duration: Int64?
        let severity: Int
        let created: String
    }
    
    // MARK: - Host Fields
    
    let host: HostFields
    
    struct HostFields: Codable {
        let name: String
        let hostname: String
        let architecture: String?
        let os: OSInfo
        
        struct OSInfo: Codable {
            let family: String
            let name: String
            let version: String
            let platform: String
        }
    }
    
    // MARK: - Service Fields
    
    let service: ServiceFields
    
    struct ServiceFields: Codable {
        let name: String
        let version: String
        let environment: String
        let type: String
    }
    
    // MARK: - Agent Fields
    
    let agent: AgentFields
    
    struct AgentFields: Codable {
        let name: String
        let version: String
        let type: String
    }
    
    // MARK: - Device Fields (Custom extension)
    
    let device: DeviceFields?
    
    struct DeviceFields: Codable {
        let type: String
        let model: String
        let vendor: String
    }
    
    // MARK: - Error Fields
    
    let error: ErrorFields?
    
    struct ErrorFields: Codable {
        let message: String?
        let type: String?
        let code: String?
        let stackTrace: String?
        
        enum CodingKeys: String, CodingKey {
            case message, type, code
            case stackTrace = "stack_trace"
        }
    }
    
    // MARK: - User Fields
    
    let user: UserFields?
    
    struct UserFields: Codable {
        let id: String?
        let name: String?
        let email: String?
    }
    
    // MARK: - Trace Fields
    
    let trace: TraceFields?
    
    struct TraceFields: Codable {
        let id: String?
    }
    
    let span: SpanFields?
    
    struct SpanFields: Codable {
        let id: String?
    }
    
    // MARK: - Custom Fields
    
    let custom: [String: AnyCodableValue]?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "@timestamp"
        case message, labels, tags, log, event, host, service, agent, device, error, user, trace, span, custom
    }
}

// MARK: - Any Codable Value

/// Type-erased codable value for dynamic fields.
private struct AnyCodableValue: Codable {
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
        } else if let array = try? container.decode([AnyCodableValue].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodableValue].self) {
            value = dict.mapValues { $0.value }
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
            try container.encode(array.map { AnyCodableValue($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodableValue($0) })
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Bulk Response

/// Response from Elasticsearch bulk API.
private struct BulkResponse: Codable {
    let took: Int
    let errors: Bool
    let items: [BulkItem]
    
    struct BulkItem: Codable {
        let index: IndexResult?
        let create: IndexResult?
        
        struct IndexResult: Codable {
            let index: String
            let id: String
            let version: Int?
            let result: String?
            let status: Int
            let error: BulkError?
            
            enum CodingKeys: String, CodingKey {
                case index = "_index"
                case id = "_id"
                case version = "_version"
                case result
                case status
                case error
            }
        }
    }
    
    struct BulkError: Codable {
        let type: String
        let reason: String
        let causedBy: CausedBy?
        
        enum CodingKeys: String, CodingKey {
            case type, reason
            case causedBy = "caused_by"
        }
        
        struct CausedBy: Codable {
            let type: String
            let reason: String
        }
    }
}

// MARK: - Elasticsearch Destination

/// A log destination that sends entries to an Elasticsearch cluster.
///
/// This destination provides full integration with Elasticsearch's document
/// storage and search capabilities, using the Elastic Common Schema (ECS)
/// for standardized log formatting.
///
/// ## Features
///
/// - Bulk API for efficient batch indexing
/// - Automatic index rotation (daily, weekly, monthly)
/// - Multiple node support with automatic failover
/// - Elastic Common Schema (ECS) compliance
/// - Gzip compression support
/// - Ingest pipeline integration
/// - SSL/TLS with custom certificates
///
/// ## Usage
///
/// ```swift
/// let config = ElasticsearchConfiguration(
///     url: URL(string: "https://localhost:9200")!,
///     authentication: .basic(username: "elastic", password: "secret"),
///     indexStrategy: .daily(prefix: "app-logs")
/// )
/// let destination = ElasticDestination(configuration: config)
/// Logger.shared.addDestination(destination)
/// ```
public final class ElasticDestination: LogDestination, @unchecked Sendable {
    
    // MARK: - LogDestination Conformance
    
    public var minimumLevel: LogLevel
    public var formatter: LogFormatter
    
    // MARK: - Properties
    
    /// The Elasticsearch configuration.
    public let configuration: ElasticsearchConfiguration
    
    /// Service name for ECS service.name field.
    public var serviceName: String
    
    /// Service version for ECS service.version field.
    public var serviceVersion: String
    
    /// Environment name for ECS service.environment field.
    public var environment: String
    
    /// Additional labels to include with every document.
    public var globalLabels: [String: String]
    
    /// Additional tags to include with every document.
    public var globalTags: [String]
    
    /// Current user information for log enrichment.
    public private(set) var currentUser: UserInfo?
    
    /// Current trace context for distributed tracing.
    public private(set) var traceContext: TraceContext?
    
    // MARK: - Private Properties
    
    private let queue: DispatchQueue
    private let urlSession: URLSession
    private var pendingDocuments: [(index: String, document: ECSDocument)] = []
    private var pendingBytes: Int = 0
    private var flushTimer: DispatchSourceTimer?
    private var currentNodeIndex: Int = 0
    private var failedNodes: Set<Int> = []
    private var nodeHealthCheckTimer: DispatchSourceTimer?
    private let persistenceURL: URL?
    private var isFlushInProgress: Bool = false
    private let deviceInfo: DeviceInfo
    private let hostInfo: HostInfo
    
    // MARK: - Nested Types
    
    /// User information for log enrichment.
    public struct UserInfo: Sendable {
        public let id: String?
        public let name: String?
        public let email: String?
        
        public init(id: String? = nil, name: String? = nil, email: String? = nil) {
            self.id = id
            self.name = name
            self.email = email
        }
    }
    
    /// Distributed tracing context.
    public struct TraceContext: Sendable {
        public let traceId: String
        public let spanId: String?
        
        public init(traceId: String, spanId: String? = nil) {
            self.traceId = traceId
            self.spanId = spanId
        }
    }
    
    /// Cached device information.
    private struct DeviceInfo {
        let type: String
        let model: String
        let vendor: String
        
        static func current() -> DeviceInfo {
            #if canImport(UIKit) && !os(watchOS)
            let device = UIDevice.current
            return DeviceInfo(
                type: device.userInterfaceIdiom == .phone ? "mobile" : "tablet",
                model: Self.modelIdentifier(),
                vendor: "Apple"
            )
            #else
            return DeviceInfo(
                type: "desktop",
                model: "Mac",
                vendor: "Apple"
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
    }
    
    /// Cached host information.
    private struct HostInfo {
        let name: String
        let hostname: String
        let architecture: String?
        let osFamily: String
        let osName: String
        let osVersion: String
        let osPlatform: String
        
        static func current() -> HostInfo {
            let processInfo = ProcessInfo.processInfo
            let version = processInfo.operatingSystemVersion
            
            #if canImport(UIKit) && !os(watchOS)
            let hostName = UIDevice.current.name
            #else
            let hostName = Host.current().localizedName ?? "Unknown"
            #endif
            
            return HostInfo(
                name: hostName,
                hostname: processInfo.hostName,
                architecture: Self.cpuArchitecture(),
                osFamily: Self.osFamily(),
                osName: Self.osName(),
                osVersion: "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)",
                osPlatform: Self.osPlatform()
            )
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
        
        private static func osFamily() -> String {
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            return "ios"
            #elseif os(macOS)
            return "darwin"
            #else
            return "unknown"
            #endif
        }
        
        private static func osName() -> String {
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
        
        private static func osPlatform() -> String {
            #if os(iOS)
            return "ios"
            #elseif os(macOS)
            return "darwin"
            #elseif os(watchOS)
            return "watchos"
            #elseif os(tvOS)
            return "tvos"
            #elseif os(visionOS)
            return "visionos"
            #else
            return "unknown"
            #endif
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a new Elasticsearch destination.
    ///
    /// - Parameters:
    ///   - configuration: Elasticsearch configuration.
    ///   - serviceName: Service name for ECS.
    ///   - serviceVersion: Service version.
    ///   - environment: Environment name.
    ///   - minimumLevel: Minimum log level.
    ///   - formatter: Log formatter.
    ///   - globalLabels: Labels for all documents.
    ///   - globalTags: Tags for all documents.
    public init(
        configuration: ElasticsearchConfiguration,
        serviceName: String = "ios-app",
        serviceVersion: String = "1.0.0",
        environment: String = "production",
        minimumLevel: LogLevel = .debug,
        formatter: LogFormatter = JSONFormatter(),
        globalLabels: [String: String] = [:],
        globalTags: [String] = []
    ) {
        self.configuration = configuration
        self.serviceName = serviceName
        self.serviceVersion = serviceVersion
        self.environment = environment
        self.minimumLevel = minimumLevel
        self.formatter = formatter
        self.globalLabels = globalLabels
        self.globalTags = globalTags
        self.deviceInfo = DeviceInfo.current()
        self.hostInfo = HostInfo.current()
        
        self.queue = DispatchQueue(
            label: "com.mobilelogger.elastic",
            qos: .utility
        )
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.requestTimeout
        sessionConfig.timeoutIntervalForResource = configuration.requestTimeout * 2
        
        if configuration.enableCompression {
            sessionConfig.httpAdditionalHeaders = ["Content-Encoding": "gzip"]
        }
        
        self.urlSession = URLSession(configuration: sessionConfig)
        
        // Setup persistence
        if let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.persistenceURL = cachesDir.appendingPathComponent("elastic_logs_buffer.json")
            loadPersistedDocuments()
        } else {
            self.persistenceURL = nil
        }
        
        startFlushTimer()
        startNodeHealthCheck()
        setupAppLifecycleObservers()
    }
    
    deinit {
        flushTimer?.cancel()
        nodeHealthCheckTimer?.cancel()
        flush(sync: true)
    }
    
    // MARK: - LogDestination
    
    public func send(_ entry: LogEntry) {
        let document = createECSDocument(from: entry)
        let indexName = configuration.indexStrategy.currentIndexName()
        
        queue.async { [weak self] in
            guard let self else { return }
            
            self.pendingDocuments.append((index: indexName, document: document))
            
            // Estimate document size
            if let data = try? JSONEncoder().encode(document) {
                self.pendingBytes += data.count
            }
            
            // Check batch limits
            if self.pendingDocuments.count >= self.configuration.maxBatchSize ||
               self.pendingBytes >= self.configuration.maxBatchBytes {
                self.performFlush()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the current user information for log enrichment.
    public func setUser(_ user: UserInfo?) {
        queue.async { [weak self] in
            self?.currentUser = user
        }
    }
    
    /// Sets the current trace context for distributed tracing.
    public func setTraceContext(_ context: TraceContext?) {
        queue.async { [weak self] in
            self?.traceContext = context
        }
    }
    
    /// Forces an immediate flush of pending documents.
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
    
    /// Returns cluster health status.
    public func checkClusterHealth(completion: @escaping (ClusterHealth?) -> Void) {
        guard let node = getAvailableNode() else {
            completion(nil)
            return
        }
        
        let healthURL = node.appendingPathComponent("_cluster/health")
        var request = URLRequest(url: healthURL)
        applyAuthentication(to: &request)
        
        urlSession.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let health = try? JSONDecoder().decode(ClusterHealth.self, from: data) else {
                completion(nil)
                return
            }
            completion(health)
        }.resume()
    }
    
    /// Cluster health response.
    public struct ClusterHealth: Codable, Sendable {
        public let clusterName: String
        public let status: String
        public let timedOut: Bool
        public let numberOfNodes: Int
        public let numberOfDataNodes: Int
        public let activePrimaryShards: Int
        public let activeShards: Int
        public let relocatingShards: Int
        public let initializingShards: Int
        public let unassignedShards: Int
        
        enum CodingKeys: String, CodingKey {
            case clusterName = "cluster_name"
            case status
            case timedOut = "timed_out"
            case numberOfNodes = "number_of_nodes"
            case numberOfDataNodes = "number_of_data_nodes"
            case activePrimaryShards = "active_primary_shards"
            case activeShards = "active_shards"
            case relocatingShards = "relocating_shards"
            case initializingShards = "initializing_shards"
            case unassignedShards = "unassigned_shards"
        }
    }
    
    /// Creates an index template for log indices.
    public func createIndexTemplate(
        name: String,
        indexPatterns: [String],
        numberOfShards: Int = 1,
        numberOfReplicas: Int = 1,
        completion: @escaping (Bool) -> Void
    ) {
        guard let node = getAvailableNode() else {
            completion(false)
            return
        }
        
        let templateURL = node.appendingPathComponent("_index_template/\(name)")
        var request = URLRequest(url: templateURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuthentication(to: &request)
        
        let template: [String: Any] = [
            "index_patterns": indexPatterns,
            "template": [
                "settings": [
                    "number_of_shards": numberOfShards,
                    "number_of_replicas": numberOfReplicas,
                    "index.lifecycle.name": "logs-policy",
                    "index.lifecycle.rollover_alias": indexPatterns.first ?? "logs"
                ],
                "mappings": [
                    "properties": [
                        "@timestamp": ["type": "date"],
                        "message": ["type": "text"],
                        "log.level": ["type": "keyword"],
                        "service.name": ["type": "keyword"],
                        "service.version": ["type": "keyword"],
                        "service.environment": ["type": "keyword"],
                        "host.name": ["type": "keyword"],
                        "host.hostname": ["type": "keyword"],
                        "error.message": ["type": "text"],
                        "error.stack_trace": ["type": "text"],
                        "user.id": ["type": "keyword"],
                        "trace.id": ["type": "keyword"],
                        "span.id": ["type": "keyword"]
                    ]
                ]
            ],
            "priority": 100
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: template)
        } catch {
            completion(false)
            return
        }
        
        urlSession.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            completion((200..<300).contains(httpResponse.statusCode))
        }.resume()
    }
    
    /// Returns the count of pending documents awaiting transmission.
    public var pendingDocumentCount: Int {
        queue.sync { pendingDocuments.count }
    }
    
    // MARK: - Private Methods
    
    private func createECSDocument(from entry: LogEntry) -> ECSDocument {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let timestamp = formatter.string(from: entry.timestamp)
        
        let fileName = (entry.file as NSString).lastPathComponent
        
        // Build labels
        var labels = globalLabels
        if let metadata = entry.metadata {
            for (key, value) in metadata where !key.hasPrefix("error.") {
                labels[key] = value
            }
        }
        
        // Build error info if applicable
        var errorInfo: ECSDocument.ErrorFields? = nil
        if entry.level >= .error {
            errorInfo = ECSDocument.ErrorFields(
                message: entry.metadata?["error.message"],
                type: entry.metadata?["error.type"],
                code: entry.metadata?["error.code"],
                stackTrace: entry.metadata?["error.stack"]
            )
        }
        
        // Build user info
        var userInfo: ECSDocument.UserFields? = nil
        if let user = currentUser {
            userInfo = ECSDocument.UserFields(
                id: user.id,
                name: user.name,
                email: user.email
            )
        }
        
        // Build trace info
        var traceInfo: ECSDocument.TraceFields? = nil
        var spanInfo: ECSDocument.SpanFields? = nil
        if let trace = traceContext {
            traceInfo = ECSDocument.TraceFields(id: trace.traceId)
            spanInfo = ECSDocument.SpanFields(id: trace.spanId)
        }
        
        return ECSDocument(
            timestamp: timestamp,
            message: entry.message,
            labels: labels.isEmpty ? nil : labels,
            tags: globalTags.isEmpty ? nil : globalTags,
            log: ECSDocument.LogFields(
                level: entry.level.rawValue,
                logger: "MobileLogger",
                origin: ECSDocument.LogFields.LogOrigin(
                    file: ECSDocument.LogFields.LogOrigin.FileInfo(
                        name: fileName,
                        line: Int(entry.line)
                    ),
                    function: entry.function
                )
            ),
            event: ECSDocument.EventFields(
                kind: "event",
                category: ["log"],
                type: nil,
                outcome: nil,
                duration: nil,
                severity: mapLevelToSeverity(entry.level),
                created: timestamp
            ),
            host: ECSDocument.HostFields(
                name: hostInfo.name,
                hostname: hostInfo.hostname,
                architecture: hostInfo.architecture,
                os: ECSDocument.HostFields.OSInfo(
                    family: hostInfo.osFamily,
                    name: hostInfo.osName,
                    version: hostInfo.osVersion,
                    platform: hostInfo.osPlatform
                )
            ),
            service: ECSDocument.ServiceFields(
                name: serviceName,
                version: serviceVersion,
                environment: environment,
                type: "mobile"
            ),
            agent: ECSDocument.AgentFields(
                name: "MobileLogger",
                version: "1.0.0",
                type: "swift-logging"
            ),
            device: ECSDocument.DeviceFields(
                type: deviceInfo.type,
                model: deviceInfo.model,
                vendor: deviceInfo.vendor
            ),
            error: errorInfo,
            user: userInfo,
            trace: traceInfo,
            span: spanInfo,
            custom: nil
        )
    }
    
    private func mapLevelToSeverity(_ level: LogLevel) -> Int {
        switch level {
        case .trace: return 0
        case .debug: return 1
        case .info: return 2
        case .warning: return 3
        case .error: return 4
        case .critical: return 5
        }
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
    
    private func startNodeHealthCheck() {
        guard configuration.nodes.count > 1 else { return }
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 60, repeating: 60)
        timer.setEventHandler { [weak self] in
            self?.checkFailedNodes()
        }
        timer.resume()
        nodeHealthCheckTimer = timer
    }
    
    private func checkFailedNodes() {
        for nodeIndex in failedNodes {
            guard nodeIndex < configuration.nodes.count else { continue }
            
            let node = configuration.nodes[nodeIndex]
            var request = URLRequest(url: node.appendingPathComponent("_cluster/health"))
            applyAuthentication(to: &request)
            
            urlSession.dataTask(with: request) { [weak self] _, response, _ in
                if let httpResponse = response as? HTTPURLResponse,
                   (200..<300).contains(httpResponse.statusCode) {
                    self?.queue.async {
                        self?.failedNodes.remove(nodeIndex)
                        if self?.configuration.debugMode == true {
                            print("[Elastic] Node \(nodeIndex) recovered")
                        }
                    }
                }
            }.resume()
        }
    }
    
    private func getAvailableNode() -> URL? {
        let availableIndices = (0..<configuration.nodes.count).filter { !failedNodes.contains($0) }
        guard !availableIndices.isEmpty else {
            // All nodes failed, try the first one anyway
            return configuration.nodes.first
        }
        
        // Round-robin selection
        let index = availableIndices[currentNodeIndex % availableIndices.count]
        currentNodeIndex = (currentNodeIndex + 1) % availableIndices.count
        return configuration.nodes[index]
    }
    
    private func markNodeAsFailed(_ nodeIndex: Int) {
        failedNodes.insert(nodeIndex)
        if configuration.debugMode {
            print("[Elastic] Marked node \(nodeIndex) as failed")
        }
    }
    
    private func applyAuthentication(to request: inout URLRequest) {
        switch configuration.authentication {
        case .none:
            break
            
        case .basic(let username, let password):
            let credentials = "\(username):\(password)"
            if let data = credentials.data(using: .utf8) {
                let base64 = data.base64EncodedString()
                request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
            
        case .apiKey(let id, let apiKey):
            let credentials = "\(id):\(apiKey)"
            if let data = credentials.data(using: .utf8) {
                let base64 = data.base64EncodedString()
                request.setValue("ApiKey \(base64)", forHTTPHeaderField: "Authorization")
            }
            
        case .bearer(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        case .cloudId(_, let apiKey):
            request.setValue("ApiKey \(apiKey)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func performFlush() {
        guard !pendingDocuments.isEmpty, !isFlushInProgress else { return }
        
        isFlushInProgress = true
        let documentsToSend = pendingDocuments
        pendingDocuments.removeAll()
        pendingBytes = 0
        
        guard let node = getAvailableNode() else {
            // Re-add documents
            pendingDocuments = documentsToSend
            isFlushInProgress = false
            return
        }
        
        sendBulk(documents: documentsToSend, to: node) { [weak self] success in
            self?.queue.async {
                self?.isFlushInProgress = false
                
                if !success {
                    // Re-add failed documents
                    self?.pendingDocuments.insert(contentsOf: documentsToSend, at: 0)
                    self?.persistPendingDocuments()
                }
            }
        }
    }
    
    private func sendBulk(
        documents: [(index: String, document: ECSDocument)],
        to node: URL,
        completion: @escaping (Bool) -> Void
    ) {
        var bulkBody = ""
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        
        for (index, document) in documents {
            // Action line
            let action: [String: Any] = [
                "index": [
                    "_index": index
                ]
            ]
            
            if let actionData = try? JSONSerialization.data(withJSONObject: action),
               let actionString = String(data: actionData, encoding: .utf8) {
                bulkBody += actionString + "\n"
            }
            
            // Document line
            if let docData = try? encoder.encode(document),
               let docString = String(data: docData, encoding: .utf8) {
                bulkBody += docString + "\n"
            }
        }
        
        var bulkURL = node.appendingPathComponent("_bulk")
        if let pipeline = configuration.pipeline {
            var components = URLComponents(url: bulkURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "pipeline", value: pipeline)]
            if let url = components?.url {
                bulkURL = url
            }
        }
        
        var request = URLRequest(url: bulkURL)
        request.httpMethod = "POST"
        request.setValue("application/x-ndjson", forHTTPHeaderField: "Content-Type")
        applyAuthentication(to: &request)
        
        var bodyData = bulkBody.data(using: .utf8)!
        
        if configuration.enableCompression {
            if let compressed = compress(data: bodyData) {
                bodyData = compressed
                request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            }
        }
        
        request.httpBody = bodyData
        
        if configuration.debugMode {
            print("[Elastic] Sending \(documents.count) documents to \(bulkURL)")
        }
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                if self?.configuration.debugMode == true {
                    print("[Elastic] Network error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                if self?.configuration.debugMode == true {
                    print("[Elastic] Server error: \(httpResponse.statusCode)")
                }
                completion(false)
                return
            }
            
            // Parse bulk response to check for individual errors
            if let data = data,
               let bulkResponse = try? JSONDecoder().decode(BulkResponse.self, from: data) {
                if bulkResponse.errors {
                    if self?.configuration.debugMode == true {
                        print("[Elastic] Bulk request had errors")
                        for item in bulkResponse.items {
                            if let error = item.index?.error ?? item.create?.error {
                                print("[Elastic] Error: \(error.type) - \(error.reason)")
                            }
                        }
                    }
                } else if self?.configuration.debugMode == true {
                    print("[Elastic] Successfully indexed \(documents.count) documents in \(bulkResponse.took)ms")
                }
            }
            
            completion(true)
        }.resume()
    }
    
    private func compress(data: Data) -> Data? {
        guard #available(iOS 13.0, macOS 10.15, *) else { return nil }
        
        var sourceBuffer = Array(data)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { destinationBuffer.deallocate() }
        
        let compressedSize = compression_encode_buffer(
            destinationBuffer,
            data.count,
            &sourceBuffer,
            data.count,
            nil,
            COMPRESSION_ZLIB
        )
        
        guard compressedSize > 0 else { return nil }
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
    
    private func persistPendingDocuments() {
        guard let url = persistenceURL else { return }
        
        let documentsData = pendingDocuments.map { (index: $0.index, document: $0.document) }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(documentsData.map { $0.document })
            try data.write(to: url)
        } catch {
            if configuration.debugMode {
                print("[Elastic] Failed to persist documents: \(error)")
            }
        }
    }
    
    private func loadPersistedDocuments() {
        guard let url = persistenceURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let documents = try decoder.decode([ECSDocument].self, from: data)
            let indexName = configuration.indexStrategy.currentIndexName()
            pendingDocuments = documents.map { (index: indexName, document: $0) }
            try FileManager.default.removeItem(at: url)
            
            if configuration.debugMode {
                print("[Elastic] Loaded \(documents.count) persisted documents")
            }
        } catch {
            if configuration.debugMode {
                print("[Elastic] Failed to load persisted documents: \(error)")
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
