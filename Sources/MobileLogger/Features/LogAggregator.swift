import Foundation

// MARK: - Log Aggregator

/// A powerful log aggregation system that collects, groups, and analyzes log entries
/// to provide insights and detect patterns.
///
/// `LogAggregator` monitors log streams in real-time and can:
/// - Group similar log entries to reduce noise
/// - Detect log patterns and anomalies
/// - Calculate statistics and metrics
/// - Generate summaries for specific time windows
///
/// ## Usage
///
/// ```swift
/// let aggregator = LogAggregator()
/// aggregator.startAggregating()
///
/// // Get statistics
/// let stats = aggregator.statistics(for: .lastHour)
/// print("Errors: \(stats.errorCount)")
/// ```
public final class LogAggregator: @unchecked Sendable {
    
    // MARK: - Configuration
    
    /// Configuration options for the aggregator.
    public struct Configuration: Sendable {
        /// Time window for grouping similar entries.
        public var groupingWindow: TimeInterval
        
        /// Maximum number of unique patterns to track.
        public var maxPatterns: Int
        
        /// Similarity threshold for grouping (0.0 to 1.0).
        public var similarityThreshold: Double
        
        /// Maximum entries to keep in memory.
        public var maxEntries: Int
        
        /// Enable automatic pattern detection.
        public var enablePatternDetection: Bool
        
        /// Enable anomaly detection.
        public var enableAnomalyDetection: Bool
        
        /// Baseline window for anomaly detection.
        public var anomalyBaselineWindow: TimeInterval
        
        /// Anomaly threshold multiplier.
        public var anomalyThreshold: Double
        
        /// Creates a default configuration.
        public init(
            groupingWindow: TimeInterval = 60,
            maxPatterns: Int = 1000,
            similarityThreshold: Double = 0.8,
            maxEntries: Int = 10000,
            enablePatternDetection: Bool = true,
            enableAnomalyDetection: Bool = true,
            anomalyBaselineWindow: TimeInterval = 3600,
            anomalyThreshold: Double = 2.0
        ) {
            self.groupingWindow = groupingWindow
            self.maxPatterns = maxPatterns
            self.similarityThreshold = similarityThreshold
            self.maxEntries = maxEntries
            self.enablePatternDetection = enablePatternDetection
            self.enableAnomalyDetection = enableAnomalyDetection
            self.anomalyBaselineWindow = anomalyBaselineWindow
            self.anomalyThreshold = anomalyThreshold
        }
    }
    
    // MARK: - Time Window
    
    /// Predefined time windows for aggregation queries.
    public enum TimeWindow: Sendable {
        /// Last 5 minutes
        case last5Minutes
        /// Last 15 minutes
        case last15Minutes
        /// Last hour
        case lastHour
        /// Last 6 hours
        case last6Hours
        /// Last 24 hours
        case last24Hours
        /// Last 7 days
        case last7Days
        /// Custom time range
        case custom(start: Date, end: Date)
        
        /// The start date for this time window.
        var startDate: Date {
            switch self {
            case .last5Minutes:
                return Date().addingTimeInterval(-5 * 60)
            case .last15Minutes:
                return Date().addingTimeInterval(-15 * 60)
            case .lastHour:
                return Date().addingTimeInterval(-3600)
            case .last6Hours:
                return Date().addingTimeInterval(-6 * 3600)
            case .last24Hours:
                return Date().addingTimeInterval(-24 * 3600)
            case .last7Days:
                return Date().addingTimeInterval(-7 * 24 * 3600)
            case .custom(let start, _):
                return start
            }
        }
        
        /// The end date for this time window.
        var endDate: Date {
            switch self {
            case .custom(_, let end):
                return end
            default:
                return Date()
            }
        }
    }
    
    // MARK: - Aggregated Entry
    
    /// An aggregated log entry representing multiple similar entries.
    public struct AggregatedEntry: Sendable, Identifiable {
        /// Unique identifier for this aggregated entry.
        public let id: UUID
        
        /// The pattern or representative message.
        public let pattern: String
        
        /// Log level of the entries.
        public let level: LogLevel
        
        /// Number of occurrences.
        public var count: Int
        
        /// First occurrence timestamp.
        public let firstSeen: Date
        
        /// Last occurrence timestamp.
        public var lastSeen: Date
        
        /// Source files that generated these entries.
        public var sources: Set<String>
        
        /// Sample entries for this group.
        public var samples: [LogEntry]
        
        /// Metadata keys that appeared in these entries.
        public var metadataKeys: Set<String>
        
        /// Creates a new aggregated entry.
        init(entry: LogEntry) {
            self.id = UUID()
            self.pattern = Self.extractPattern(from: entry.message)
            self.level = entry.level
            self.count = 1
            self.firstSeen = entry.timestamp
            self.lastSeen = entry.timestamp
            self.sources = [entry.file]
            self.samples = [entry]
            self.metadataKeys = Set(entry.metadata?.keys ?? [])
        }
        
        /// Extracts a pattern from a message by replacing variable parts.
        private static func extractPattern(from message: String) -> String {
            var pattern = message
            
            // Replace UUIDs
            let uuidRegex = try? NSRegularExpression(
                pattern: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
                options: []
            )
            pattern = uuidRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<UUID>"
            ) ?? pattern
            
            // Replace numbers
            let numberRegex = try? NSRegularExpression(
                pattern: "\\b\\d+\\b",
                options: []
            )
            pattern = numberRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<NUM>"
            ) ?? pattern
            
            // Replace IP addresses
            let ipRegex = try? NSRegularExpression(
                pattern: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",
                options: []
            )
            pattern = ipRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<IP>"
            ) ?? pattern
            
            // Replace email addresses
            let emailRegex = try? NSRegularExpression(
                pattern: "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
                options: []
            )
            pattern = emailRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<EMAIL>"
            ) ?? pattern
            
            // Replace hex strings
            let hexRegex = try? NSRegularExpression(
                pattern: "\\b0x[0-9a-fA-F]+\\b",
                options: []
            )
            pattern = hexRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<HEX>"
            ) ?? pattern
            
            // Replace timestamps
            let timestampRegex = try? NSRegularExpression(
                pattern: "\\d{4}-\\d{2}-\\d{2}[T ]\\d{2}:\\d{2}:\\d{2}",
                options: []
            )
            pattern = timestampRegex?.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<TIMESTAMP>"
            ) ?? pattern
            
            return pattern
        }
        
        /// Adds an entry to this aggregated group.
        mutating func add(_ entry: LogEntry, maxSamples: Int = 5) {
            count += 1
            lastSeen = entry.timestamp
            sources.insert(entry.file)
            
            if let keys = entry.metadata?.keys {
                metadataKeys.formUnion(keys)
            }
            
            if samples.count < maxSamples {
                samples.append(entry)
            }
        }
    }
    
    // MARK: - Statistics
    
    /// Statistics for a time window.
    public struct Statistics: Sendable {
        /// Total number of log entries.
        public let totalCount: Int
        
        /// Count by log level.
        public let countByLevel: [LogLevel: Int]
        
        /// Count by source file.
        public let countBySource: [String: Int]
        
        /// Average entries per minute.
        public let entriesPerMinute: Double
        
        /// Peak entries in any minute.
        public let peakEntriesPerMinute: Int
        
        /// Most common patterns.
        public let topPatterns: [PatternStat]
        
        /// Error rate (errors / total).
        public let errorRate: Double
        
        /// Time window duration.
        public let windowDuration: TimeInterval
        
        /// Pattern statistic.
        public struct PatternStat: Sendable {
            public let pattern: String
            public let count: Int
            public let percentage: Double
        }
    }
    
    // MARK: - Anomaly
    
    /// Represents a detected anomaly in log patterns.
    public struct Anomaly: Sendable, Identifiable {
        /// Unique identifier.
        public let id: UUID
        
        /// Type of anomaly detected.
        public let type: AnomalyType
        
        /// Severity level.
        public let severity: Severity
        
        /// Description of the anomaly.
        public let description: String
        
        /// Detection timestamp.
        public let detectedAt: Date
        
        /// Related log entries.
        public let relatedEntries: [LogEntry]
        
        /// Baseline value (what was expected).
        public let baseline: Double
        
        /// Actual value observed.
        public let actual: Double
        
        /// Deviation from baseline.
        public var deviation: Double {
            guard baseline > 0 else { return 0 }
            return (actual - baseline) / baseline * 100
        }
        
        /// Anomaly types.
        public enum AnomalyType: String, Sendable, CaseIterable {
            case volumeSpike = "volume_spike"
            case volumeDrop = "volume_drop"
            case errorSpike = "error_spike"
            case newPattern = "new_pattern"
            case patternDisappearance = "pattern_disappearance"
            case latencyIncrease = "latency_increase"
            case unusualSource = "unusual_source"
        }
        
        /// Severity levels.
        public enum Severity: String, Sendable, CaseIterable, Comparable {
            case low
            case medium
            case high
            case critical
            
            public static func < (lhs: Severity, rhs: Severity) -> Bool {
                let order: [Severity] = [.low, .medium, .high, .critical]
                return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
            }
        }
    }
    
    // MARK: - Properties
    
    /// Configuration for the aggregator.
    public let configuration: Configuration
    
    /// Whether aggregation is currently active.
    public private(set) var isAggregating: Bool = false
    
    /// Delegate for receiving aggregation events.
    public weak var delegate: LogAggregatorDelegate?
    
    // MARK: - Private Properties
    
    private let queue: DispatchQueue
    private var entries: [LogEntry] = []
    private var aggregatedEntries: [String: AggregatedEntry] = [:]
    private var patternCounts: [String: Int] = [:]
    private var levelCounts: [LogLevel: Int] = [:]
    private var minuteBuckets: [Int: Int] = [:] // minute timestamp -> count
    private var detectedAnomalies: [Anomaly] = []
    private var baselineStats: Statistics?
    private var lastBaselineUpdate: Date?
    private var patternFirstSeen: [String: Date] = [:]
    private var recentPatterns: Set<String> = []
    
    // MARK: - Initialization
    
    /// Creates a new log aggregator with the specified configuration.
    ///
    /// - Parameter configuration: Aggregator configuration.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.queue = DispatchQueue(
            label: "com.mobilelogger.aggregator",
            qos: .utility
        )
    }
    
    // MARK: - Public Methods
    
    /// Starts aggregating log entries.
    public func startAggregating() {
        queue.async { [weak self] in
            self?.isAggregating = true
        }
    }
    
    /// Stops aggregating log entries.
    public func stopAggregating() {
        queue.async { [weak self] in
            self?.isAggregating = false
        }
    }
    
    /// Processes a log entry for aggregation.
    ///
    /// - Parameter entry: The log entry to process.
    public func process(_ entry: LogEntry) {
        queue.async { [weak self] in
            self?.processEntry(entry)
        }
    }
    
    /// Processes multiple log entries.
    ///
    /// - Parameter entries: The log entries to process.
    public func process(_ entries: [LogEntry]) {
        queue.async { [weak self] in
            for entry in entries {
                self?.processEntry(entry)
            }
        }
    }
    
    /// Returns aggregated entries for a time window.
    ///
    /// - Parameter window: The time window to query.
    /// - Returns: Array of aggregated entries.
    public func aggregatedEntries(for window: TimeWindow) -> [AggregatedEntry] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            return aggregatedEntries.values
                .filter { $0.lastSeen >= start && $0.firstSeen <= end }
                .sorted { $0.count > $1.count }
        }
    }
    
    /// Returns statistics for a time window.
    ///
    /// - Parameter window: The time window to query.
    /// - Returns: Aggregation statistics.
    public func statistics(for window: TimeWindow) -> Statistics {
        queue.sync {
            calculateStatistics(for: window)
        }
    }
    
    /// Returns detected anomalies.
    ///
    /// - Parameter minSeverity: Minimum severity to include.
    /// - Returns: Array of detected anomalies.
    public func anomalies(minSeverity: Anomaly.Severity = .low) -> [Anomaly] {
        queue.sync {
            detectedAnomalies
                .filter { $0.severity >= minSeverity }
                .sorted { $0.detectedAt > $1.detectedAt }
        }
    }
    
    /// Clears an anomaly by ID.
    ///
    /// - Parameter id: The anomaly ID to clear.
    public func clearAnomaly(_ id: UUID) {
        queue.async { [weak self] in
            self?.detectedAnomalies.removeAll { $0.id == id }
        }
    }
    
    /// Clears all detected anomalies.
    public func clearAllAnomalies() {
        queue.async { [weak self] in
            self?.detectedAnomalies.removeAll()
        }
    }
    
    /// Returns the top patterns by occurrence count.
    ///
    /// - Parameters:
    ///   - limit: Maximum patterns to return.
    ///   - window: Time window to analyze.
    /// - Returns: Array of patterns with counts.
    public func topPatterns(limit: Int = 10, for window: TimeWindow) -> [(pattern: String, count: Int)] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            let relevantPatterns = aggregatedEntries.values
                .filter { $0.lastSeen >= start && $0.firstSeen <= end }
                .map { ($0.pattern, $0.count) }
                .sorted { $0.1 > $1.1 }
                .prefix(limit)
            
            return Array(relevantPatterns)
        }
    }
    
    /// Returns entries grouped by source file.
    ///
    /// - Parameter window: Time window to analyze.
    /// - Returns: Dictionary of source files to entry counts.
    public func entriesBySource(for window: TimeWindow) -> [String: Int] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            var result: [String: Int] = [:]
            
            for entry in entries where entry.timestamp >= start && entry.timestamp <= end {
                let fileName = (entry.file as NSString).lastPathComponent
                result[fileName, default: 0] += 1
            }
            
            return result
        }
    }
    
    /// Returns entries grouped by log level.
    ///
    /// - Parameter window: Time window to analyze.
    /// - Returns: Dictionary of log levels to entry counts.
    public func entriesByLevel(for window: TimeWindow) -> [LogLevel: Int] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            var result: [LogLevel: Int] = [:]
            
            for entry in entries where entry.timestamp >= start && entry.timestamp <= end {
                result[entry.level, default: 0] += 1
            }
            
            return result
        }
    }
    
    /// Returns time-series data for charting.
    ///
    /// - Parameters:
    ///   - window: Time window to analyze.
    ///   - granularity: Bucket size in seconds.
    /// - Returns: Array of (timestamp, count) tuples.
    public func timeSeries(
        for window: TimeWindow,
        granularity: TimeInterval = 60
    ) -> [(timestamp: Date, count: Int)] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            var buckets: [Int: Int] = [:]
            let granularityInt = Int(granularity)
            
            for entry in entries where entry.timestamp >= start && entry.timestamp <= end {
                let bucket = Int(entry.timestamp.timeIntervalSince1970) / granularityInt
                buckets[bucket, default: 0] += 1
            }
            
            return buckets
                .map { (timestamp: Date(timeIntervalSince1970: TimeInterval($0.key * granularityInt)), count: $0.value) }
                .sorted { $0.timestamp < $1.timestamp }
        }
    }
    
    /// Returns error time-series data.
    ///
    /// - Parameters:
    ///   - window: Time window to analyze.
    ///   - granularity: Bucket size in seconds.
    /// - Returns: Array of (timestamp, errorCount, totalCount) tuples.
    public func errorTimeSeries(
        for window: TimeWindow,
        granularity: TimeInterval = 60
    ) -> [(timestamp: Date, errorCount: Int, totalCount: Int)] {
        queue.sync {
            let start = window.startDate
            let end = window.endDate
            
            var errorBuckets: [Int: Int] = [:]
            var totalBuckets: [Int: Int] = [:]
            let granularityInt = Int(granularity)
            
            for entry in entries where entry.timestamp >= start && entry.timestamp <= end {
                let bucket = Int(entry.timestamp.timeIntervalSince1970) / granularityInt
                totalBuckets[bucket, default: 0] += 1
                
                if entry.level >= .error {
                    errorBuckets[bucket, default: 0] += 1
                }
            }
            
            let allBuckets = Set(errorBuckets.keys).union(totalBuckets.keys)
            
            return allBuckets
                .map { bucket in
                    (
                        timestamp: Date(timeIntervalSince1970: TimeInterval(bucket * granularityInt)),
                        errorCount: errorBuckets[bucket] ?? 0,
                        totalCount: totalBuckets[bucket] ?? 0
                    )
                }
                .sorted { $0.timestamp < $1.timestamp }
        }
    }
    
    /// Resets all aggregation data.
    public func reset() {
        queue.async { [weak self] in
            self?.entries.removeAll()
            self?.aggregatedEntries.removeAll()
            self?.patternCounts.removeAll()
            self?.levelCounts.removeAll()
            self?.minuteBuckets.removeAll()
            self?.detectedAnomalies.removeAll()
            self?.baselineStats = nil
            self?.patternFirstSeen.removeAll()
            self?.recentPatterns.removeAll()
        }
    }
    
    /// Updates the baseline statistics for anomaly detection.
    public func updateBaseline() {
        queue.async { [weak self] in
            self?.calculateBaseline()
        }
    }
    
    // MARK: - Private Methods
    
    private func processEntry(_ entry: LogEntry) {
        guard isAggregating else { return }
        
        // Store entry
        entries.append(entry)
        
        // Enforce max entries limit
        if entries.count > configuration.maxEntries {
            let removeCount = entries.count - configuration.maxEntries
            entries.removeFirst(removeCount)
        }
        
        // Update level counts
        levelCounts[entry.level, default: 0] += 1
        
        // Update minute bucket
        let minuteKey = Int(entry.timestamp.timeIntervalSince1970 / 60)
        minuteBuckets[minuteKey, default: 0] += 1
        
        // Pattern detection
        if configuration.enablePatternDetection {
            let pattern = AggregatedEntry.extractPattern(from: entry)
            patternCounts[pattern, default: 0] += 1
            
            if var existing = aggregatedEntries[pattern] {
                existing.add(entry)
                aggregatedEntries[pattern] = existing
            } else {
                let aggregated = AggregatedEntry(entry: entry)
                aggregatedEntries[pattern] = aggregated
                
                // Track new pattern
                if patternFirstSeen[pattern] == nil {
                    patternFirstSeen[pattern] = entry.timestamp
                    
                    // Check if this is a genuinely new pattern (anomaly)
                    if configuration.enableAnomalyDetection,
                       let baseline = baselineStats,
                       !recentPatterns.contains(pattern) {
                        detectNewPatternAnomaly(pattern: pattern, entry: entry)
                    }
                }
            }
            
            recentPatterns.insert(pattern)
        }
        
        // Anomaly detection
        if configuration.enableAnomalyDetection {
            checkForAnomalies(entry: entry)
        }
        
        // Update baseline periodically
        if lastBaselineUpdate == nil ||
           Date().timeIntervalSince(lastBaselineUpdate!) > configuration.anomalyBaselineWindow / 4 {
            calculateBaseline()
        }
        
        // Enforce max patterns limit
        if aggregatedEntries.count > configuration.maxPatterns {
            prunePatterns()
        }
        
        // Notify delegate
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.aggregator(self!, didProcess: entry)
        }
    }
    
    private func calculateStatistics(for window: TimeWindow) -> Statistics {
        let start = window.startDate
        let end = window.endDate
        let duration = end.timeIntervalSince(start)
        
        let relevantEntries = entries.filter {
            $0.timestamp >= start && $0.timestamp <= end
        }
        
        let totalCount = relevantEntries.count
        
        // Count by level
        var levelCounts: [LogLevel: Int] = [:]
        for entry in relevantEntries {
            levelCounts[entry.level, default: 0] += 1
        }
        
        // Count by source
        var sourceCounts: [String: Int] = [:]
        for entry in relevantEntries {
            let fileName = (entry.file as NSString).lastPathComponent
            sourceCounts[fileName, default: 0] += 1
        }
        
        // Entries per minute
        let minutes = duration / 60
        let entriesPerMinute = minutes > 0 ? Double(totalCount) / minutes : 0
        
        // Peak entries per minute
        let minuteStart = Int(start.timeIntervalSince1970 / 60)
        let minuteEnd = Int(end.timeIntervalSince1970 / 60)
        let peakEntries = (minuteStart...minuteEnd)
            .map { minuteBuckets[$0] ?? 0 }
            .max() ?? 0
        
        // Top patterns
        let relevantAggregated = aggregatedEntries.values
            .filter { $0.lastSeen >= start && $0.firstSeen <= end }
            .sorted { $0.count > $1.count }
            .prefix(10)
        
        let topPatterns = relevantAggregated.map { aggregated in
            Statistics.PatternStat(
                pattern: aggregated.pattern,
                count: aggregated.count,
                percentage: totalCount > 0 ? Double(aggregated.count) / Double(totalCount) * 100 : 0
            )
        }
        
        // Error rate
        let errorCount = (levelCounts[.error] ?? 0) + (levelCounts[.critical] ?? 0)
        let errorRate = totalCount > 0 ? Double(errorCount) / Double(totalCount) : 0
        
        return Statistics(
            totalCount: totalCount,
            countByLevel: levelCounts,
            countBySource: sourceCounts,
            entriesPerMinute: entriesPerMinute,
            peakEntriesPerMinute: peakEntries,
            topPatterns: Array(topPatterns),
            errorRate: errorRate,
            windowDuration: duration
        )
    }
    
    private func calculateBaseline() {
        let window = TimeWindow.custom(
            start: Date().addingTimeInterval(-configuration.anomalyBaselineWindow),
            end: Date()
        )
        baselineStats = calculateStatistics(for: window)
        lastBaselineUpdate = Date()
    }
    
    private func checkForAnomalies(entry: LogEntry) {
        guard let baseline = baselineStats else { return }
        
        // Check for volume spike
        let currentMinute = Int(Date().timeIntervalSince1970 / 60)
        let currentCount = minuteBuckets[currentMinute] ?? 0
        let baselinePerMinute = baseline.entriesPerMinute
        
        if baselinePerMinute > 0 {
            let ratio = Double(currentCount) / baselinePerMinute
            if ratio > configuration.anomalyThreshold {
                let anomaly = Anomaly(
                    id: UUID(),
                    type: .volumeSpike,
                    severity: ratio > configuration.anomalyThreshold * 2 ? .high : .medium,
                    description: "Log volume spike detected: \(currentCount) entries/min vs baseline \(Int(baselinePerMinute))",
                    detectedAt: Date(),
                    relatedEntries: [entry],
                    baseline: baselinePerMinute,
                    actual: Double(currentCount)
                )
                addAnomaly(anomaly)
            }
        }
        
        // Check for error spike
        if entry.level >= .error {
            let recentErrors = entries
                .filter { $0.timestamp > Date().addingTimeInterval(-60) && $0.level >= .error }
                .count
            
            let baselineErrorRate = baseline.errorRate * baseline.entriesPerMinute
            
            if baselineErrorRate > 0 {
                let ratio = Double(recentErrors) / baselineErrorRate
                if ratio > configuration.anomalyThreshold {
                    let anomaly = Anomaly(
                        id: UUID(),
                        type: .errorSpike,
                        severity: .high,
                        description: "Error rate spike detected: \(recentErrors) errors/min vs baseline \(Int(baselineErrorRate))",
                        detectedAt: Date(),
                        relatedEntries: [entry],
                        baseline: baselineErrorRate,
                        actual: Double(recentErrors)
                    )
                    addAnomaly(anomaly)
                }
            }
        }
    }
    
    private func detectNewPatternAnomaly(pattern: String, entry: LogEntry) {
        // Only flag if we have enough baseline data
        guard baselineStats != nil, entries.count > 100 else { return }
        
        let anomaly = Anomaly(
            id: UUID(),
            type: .newPattern,
            severity: entry.level >= .error ? .medium : .low,
            description: "New log pattern detected: \(pattern.prefix(100))...",
            detectedAt: Date(),
            relatedEntries: [entry],
            baseline: 0,
            actual: 1
        )
        addAnomaly(anomaly)
    }
    
    private func addAnomaly(_ anomaly: Anomaly) {
        // Deduplicate similar anomalies within 5 minutes
        let recentSimilar = detectedAnomalies.contains {
            $0.type == anomaly.type &&
            Date().timeIntervalSince($0.detectedAt) < 300
        }
        
        guard !recentSimilar else { return }
        
        detectedAnomalies.append(anomaly)
        
        // Keep only recent anomalies
        let cutoff = Date().addingTimeInterval(-24 * 3600)
        detectedAnomalies.removeAll { $0.detectedAt < cutoff }
        
        // Notify delegate
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.aggregator(self, didDetect: anomaly)
        }
    }
    
    private func prunePatterns() {
        // Remove least recently seen patterns
        let sorted = aggregatedEntries.values.sorted { $0.lastSeen < $1.lastSeen }
        let toRemove = sorted.prefix(aggregatedEntries.count - configuration.maxPatterns)
        
        for entry in toRemove {
            aggregatedEntries.removeValue(forKey: entry.pattern)
            patternCounts.removeValue(forKey: entry.pattern)
        }
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for receiving aggregation events.
public protocol LogAggregatorDelegate: AnyObject {
    /// Called when an entry is processed.
    func aggregator(_ aggregator: LogAggregator, didProcess entry: LogEntry)
    
    /// Called when an anomaly is detected.
    func aggregator(_ aggregator: LogAggregator, didDetect anomaly: LogAggregator.Anomaly)
}

// MARK: - Default Implementation

extension LogAggregatorDelegate {
    public func aggregator(_ aggregator: LogAggregator, didProcess entry: LogEntry) {}
    public func aggregator(_ aggregator: LogAggregator, didDetect anomaly: LogAggregator.Anomaly) {}
}

// MARK: - Pattern Similarity Helper

extension LogAggregator {
    
    /// Calculates similarity between two patterns using Levenshtein distance.
    ///
    /// - Parameters:
    ///   - pattern1: First pattern.
    ///   - pattern2: Second pattern.
    /// - Returns: Similarity score from 0.0 to 1.0.
    public func similarity(between pattern1: String, and pattern2: String) -> Double {
        let distance = levenshteinDistance(pattern1, pattern2)
        let maxLength = max(pattern1.count, pattern2.count)
        
        guard maxLength > 0 else { return 1.0 }
        
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        if m == 0 { return n }
        if n == 0 { return m }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[m][n]
    }
}

// MARK: - Extracting Patterns Helper

private extension String {
    func extractPattern() -> String {
        LogAggregator.AggregatedEntry.extractPattern(from: self)
    }
}

// MARK: - Extract Pattern Static Access

private extension LogAggregator.AggregatedEntry {
    static func extractPattern(from message: String) -> String {
        var pattern = message
        
        // Replace UUIDs
        if let uuidRegex = try? NSRegularExpression(
            pattern: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
            options: []
        ) {
            pattern = uuidRegex.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<UUID>"
            )
        }
        
        // Replace numbers
        if let numberRegex = try? NSRegularExpression(
            pattern: "\\b\\d+\\b",
            options: []
        ) {
            pattern = numberRegex.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<NUM>"
            )
        }
        
        // Replace IP addresses
        if let ipRegex = try? NSRegularExpression(
            pattern: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",
            options: []
        ) {
            pattern = ipRegex.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<IP>"
            )
        }
        
        // Replace email addresses
        if let emailRegex = try? NSRegularExpression(
            pattern: "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
            options: []
        ) {
            pattern = emailRegex.stringByReplacingMatches(
                in: pattern,
                options: [],
                range: NSRange(pattern.startIndex..., in: pattern),
                withTemplate: "<EMAIL>"
            )
        }
        
        return pattern
    }
}
