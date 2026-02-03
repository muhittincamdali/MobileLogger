import Foundation

// MARK: - FileRotationPolicy

/// Defines the strategy for rotating log files.
///
/// Different rotation policies allow you to control when log files
/// are archived based on size, time, or a combination of both.
///
/// ```swift
/// let policy = FileRotationPolicy.composite([
///     .size(maxBytes: 5_000_000),
///     .time(interval: .daily)
/// ])
/// ```
public enum FileRotationPolicy: Sendable, Equatable {

    /// Rotate when file exceeds a maximum size in bytes.
    case size(maxBytes: UInt64)

    /// Rotate based on a time interval.
    case time(interval: RotationInterval)

    /// Rotate when either size or time threshold is exceeded.
    case composite([FileRotationPolicy])

    /// Rotate based on a custom predicate.
    case custom(id: String)

    /// Never rotate the log file.
    case never

    // MARK: - Equatable

    public static func == (lhs: FileRotationPolicy, rhs: FileRotationPolicy) -> Bool {
        switch (lhs, rhs) {
        case let (.size(l), .size(r)):
            return l == r
        case let (.time(l), .time(r)):
            return l == r
        case let (.composite(l), .composite(r)):
            return l == r
        case let (.custom(l), .custom(r)):
            return l == r
        case (.never, .never):
            return true
        default:
            return false
        }
    }
}

// MARK: - RotationInterval

/// Time intervals for time-based log rotation.
///
/// Predefined intervals make it easy to set up common rotation schedules.
public enum RotationInterval: Sendable, Equatable {

    /// Rotate logs every hour.
    case hourly

    /// Rotate logs at midnight every day.
    case daily

    /// Rotate logs at midnight on Sunday.
    case weekly

    /// Rotate logs on the first of each month.
    case monthly

    /// Rotate logs after a custom number of seconds.
    case custom(seconds: TimeInterval)

    /// Returns the interval duration in seconds.
    public var seconds: TimeInterval {
        switch self {
        case .hourly:
            return 3600
        case .daily:
            return 86400
        case .weekly:
            return 604800
        case .monthly:
            return 2_592_000
        case let .custom(value):
            return value
        }
    }
}

// MARK: - RotationCompressionFormat

/// Compression formats for archived log files.
///
/// Compressing rotated logs saves disk space while preserving data.
public enum RotationCompressionFormat: String, Sendable, CaseIterable {

    /// No compression applied.
    case none

    /// Gzip compression (.gz extension).
    case gzip

    /// Zip archive format (.zip extension).
    case zip

    /// Returns the file extension for this compression format.
    public var fileExtension: String {
        switch self {
        case .none:
            return ""
        case .gzip:
            return ".gz"
        case .zip:
            return ".zip"
        }
    }
}

// MARK: - RotationNamingStrategy

/// Strategies for naming rotated log files.
///
/// Different naming strategies help organize archived logs.
public enum RotationNamingStrategy: Sendable, Equatable {

    /// Numeric suffix (app.1.log, app.2.log).
    case numeric

    /// Timestamp suffix (app.2026-01-15.log).
    case timestamp(format: String)

    /// Combined timestamp and sequence (app.2026-01-15.1.log).
    case timestampSequence(format: String)

    /// Custom naming with a prefix and suffix.
    case custom(prefix: String, suffix: String)

    /// The default date format for timestamp-based naming.
    public static let defaultDateFormat = "yyyy-MM-dd-HHmmss"
}

// MARK: - FileRotationConfiguration

/// Configuration options for file rotation behavior.
///
/// Customize how logs are rotated, compressed, and archived.
///
/// ```swift
/// let config = FileRotationConfiguration(
///     policy: .size(maxBytes: 10_000_000),
///     maxArchivedFiles: 10,
///     compressionFormat: .gzip,
///     namingStrategy: .timestamp(format: "yyyy-MM-dd")
/// )
/// ```
public struct FileRotationConfiguration: Sendable {

    /// The rotation policy determining when files are rotated.
    public var policy: FileRotationPolicy

    /// Maximum number of archived files to retain.
    public var maxArchivedFiles: Int

    /// Compression format for archived files.
    public var compressionFormat: RotationCompressionFormat

    /// Strategy for naming archived files.
    public var namingStrategy: RotationNamingStrategy

    /// Directory for storing archived log files.
    public var archiveDirectory: URL?

    /// Whether to delete archived files when limit is exceeded.
    public var deleteOldArchives: Bool

    /// Optional callback invoked after each rotation.
    public var onRotation: (@Sendable (RotationEvent) -> Void)?

    // MARK: - Defaults

    /// Creates a configuration with sensible defaults.
    public static var `default`: FileRotationConfiguration {
        FileRotationConfiguration(
            policy: .size(maxBytes: 10_000_000),
            maxArchivedFiles: 5,
            compressionFormat: .none,
            namingStrategy: .numeric,
            archiveDirectory: nil,
            deleteOldArchives: true,
            onRotation: nil
        )
    }

    // MARK: - Initialization

    /// Creates a new rotation configuration.
    ///
    /// - Parameters:
    ///   - policy: When to rotate files.
    ///   - maxArchivedFiles: Number of archives to keep.
    ///   - compressionFormat: How to compress archives.
    ///   - namingStrategy: How to name archives.
    ///   - archiveDirectory: Where to store archives.
    ///   - deleteOldArchives: Whether to auto-delete old archives.
    ///   - onRotation: Callback after rotation.
    public init(
        policy: FileRotationPolicy,
        maxArchivedFiles: Int = 5,
        compressionFormat: RotationCompressionFormat = .none,
        namingStrategy: RotationNamingStrategy = .numeric,
        archiveDirectory: URL? = nil,
        deleteOldArchives: Bool = true,
        onRotation: (@Sendable (RotationEvent) -> Void)? = nil
    ) {
        self.policy = policy
        self.maxArchivedFiles = maxArchivedFiles
        self.compressionFormat = compressionFormat
        self.namingStrategy = namingStrategy
        self.archiveDirectory = archiveDirectory
        self.deleteOldArchives = deleteOldArchives
        self.onRotation = onRotation
    }
}

// MARK: - RotationEvent

/// Information about a completed rotation event.
///
/// Passed to the `onRotation` callback after each rotation.
public struct RotationEvent: Sendable {

    /// The original log file that was rotated.
    public let originalFile: URL

    /// The new archived file location.
    public let archivedFile: URL

    /// The timestamp when rotation occurred.
    public let timestamp: Date

    /// Size of the rotated file in bytes.
    public let fileSize: UInt64

    /// Number of archived files now present.
    public let archivedFileCount: Int

    /// Files that were deleted during cleanup.
    public let deletedFiles: [URL]

    // MARK: - Initialization

    /// Creates a new rotation event.
    public init(
        originalFile: URL,
        archivedFile: URL,
        timestamp: Date = Date(),
        fileSize: UInt64,
        archivedFileCount: Int,
        deletedFiles: [URL] = []
    ) {
        self.originalFile = originalFile
        self.archivedFile = archivedFile
        self.timestamp = timestamp
        self.fileSize = fileSize
        self.archivedFileCount = archivedFileCount
        self.deletedFiles = deletedFiles
    }
}

// MARK: - FileRotationManager

/// Manages automatic log file rotation based on configurable policies.
///
/// The rotation manager monitors log files and automatically rotates them
/// when the configured policy conditions are met.
///
/// ```swift
/// let manager = FileRotationManager(
///     fileURL: logsDirectory.appendingPathComponent("app.log"),
///     configuration: .default
/// )
/// manager.startMonitoring()
/// ```
public final class FileRotationManager: @unchecked Sendable {

    // MARK: - Properties

    /// The active log file being monitored.
    public let fileURL: URL

    /// Configuration controlling rotation behavior.
    public var configuration: FileRotationConfiguration

    /// Whether the manager is currently monitoring.
    public private(set) var isMonitoring: Bool = false

    // MARK: - Private

    /// Serial queue for thread-safe operations.
    private let queue = DispatchQueue(label: "com.mobilelogger.rotation", qos: .utility)

    /// File manager for disk operations.
    private let fileManager = FileManager.default

    /// Timer for time-based rotation checks.
    private var monitorTimer: DispatchSourceTimer?

    /// Date formatter for timestamp-based naming.
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = RotationNamingStrategy.defaultDateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Timestamp of the last rotation.
    private var lastRotationTime: Date = Date()

    /// Current sequence number for numeric naming.
    private var sequenceNumber: Int = 0

    // MARK: - Initialization

    /// Creates a new rotation manager.
    ///
    /// - Parameters:
    ///   - fileURL: The log file to manage.
    ///   - configuration: Rotation configuration.
    public init(fileURL: URL, configuration: FileRotationConfiguration = .default) {
        self.fileURL = fileURL
        self.configuration = configuration
        loadSequenceNumber()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Starts monitoring the log file for rotation conditions.
    public func startMonitoring() {
        queue.async { [weak self] in
            guard let self, !self.isMonitoring else { return }

            self.isMonitoring = true
            self.setupMonitorTimer()
        }
    }

    /// Stops monitoring the log file.
    public func stopMonitoring() {
        queue.async { [weak self] in
            guard let self else { return }

            self.isMonitoring = false
            self.monitorTimer?.cancel()
            self.monitorTimer = nil
        }
    }

    /// Forces an immediate rotation regardless of policy.
    ///
    /// - Returns: The URL of the archived file.
    @discardableResult
    public func forceRotation() -> URL? {
        var result: URL?
        queue.sync {
            result = performRotation()
        }
        return result
    }

    /// Checks if rotation is needed based on the current policy.
    ///
    /// - Returns: `true` if rotation conditions are met.
    public func shouldRotate() -> Bool {
        queue.sync {
            checkRotationConditions()
        }
    }

    /// Returns a list of all archived log files.
    ///
    /// - Returns: Array of archived file URLs.
    public func archivedFiles() -> [URL] {
        queue.sync {
            findArchivedFiles()
        }
    }

    /// Removes all archived log files.
    ///
    /// - Returns: Number of files deleted.
    @discardableResult
    public func clearArchives() -> Int {
        queue.sync {
            let files = findArchivedFiles()
            var deleted = 0
            for file in files {
                do {
                    try fileManager.removeItem(at: file)
                    deleted += 1
                } catch {
                    // Continue deleting other files
                }
            }
            return deleted
        }
    }

    /// Returns the current size of the active log file.
    ///
    /// - Returns: File size in bytes.
    public func currentFileSize() -> UInt64 {
        queue.sync {
            getFileSize(fileURL)
        }
    }

    /// Returns statistics about the rotation manager.
    ///
    /// - Returns: A statistics object.
    public func statistics() -> RotationStatistics {
        queue.sync {
            let archives = findArchivedFiles()
            let totalSize = archives.reduce(0) { $0 + getFileSize($1) }
            return RotationStatistics(
                archivedFileCount: archives.count,
                totalArchivedSize: totalSize,
                currentFileSize: getFileSize(fileURL),
                lastRotationTime: lastRotationTime,
                sequenceNumber: sequenceNumber
            )
        }
    }

    // MARK: - Private Methods

    /// Sets up the timer for periodic rotation checks.
    private func setupMonitorTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 60, repeating: 60)
        timer.setEventHandler { [weak self] in
            self?.checkAndRotate()
        }
        timer.resume()
        monitorTimer = timer
    }

    /// Checks conditions and rotates if necessary.
    private func checkAndRotate() {
        guard checkRotationConditions() else { return }
        performRotation()
    }

    /// Evaluates whether rotation conditions are met.
    private func checkRotationConditions() -> Bool {
        switch configuration.policy {
        case let .size(maxBytes):
            return getFileSize(fileURL) >= maxBytes

        case let .time(interval):
            return Date().timeIntervalSince(lastRotationTime) >= interval.seconds

        case let .composite(policies):
            return policies.contains { policy in
                switch policy {
                case let .size(maxBytes):
                    return getFileSize(fileURL) >= maxBytes
                case let .time(interval):
                    return Date().timeIntervalSince(lastRotationTime) >= interval.seconds
                default:
                    return false
                }
            }

        case .custom:
            return false

        case .never:
            return false
        }
    }

    /// Performs the actual file rotation.
    @discardableResult
    private func performRotation() -> URL? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        let fileSize = getFileSize(fileURL)
        let archiveURL = generateArchiveURL()

        do {
            // Move current file to archive
            try fileManager.moveItem(at: fileURL, to: archiveURL)

            // Create fresh log file
            fileManager.createFile(atPath: fileURL.path, contents: nil)

            // Compress if needed
            let finalArchiveURL = compressIfNeeded(archiveURL)

            // Cleanup old archives
            let deletedFiles = cleanupOldArchives()

            // Update state
            sequenceNumber += 1
            lastRotationTime = Date()
            saveSequenceNumber()

            // Notify callback
            let event = RotationEvent(
                originalFile: fileURL,
                archivedFile: finalArchiveURL,
                fileSize: fileSize,
                archivedFileCount: findArchivedFiles().count,
                deletedFiles: deletedFiles
            )
            configuration.onRotation?(event)

            return finalArchiveURL

        } catch {
            return nil
        }
    }

    /// Generates the URL for the archived file.
    private func generateArchiveURL() -> URL {
        let directory = configuration.archiveDirectory ?? fileURL.deletingLastPathComponent()
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let ext = fileURL.pathExtension

        let archiveName: String
        switch configuration.namingStrategy {
        case .numeric:
            archiveName = "\(baseName).\(sequenceNumber + 1)"

        case let .timestamp(format):
            dateFormatter.dateFormat = format
            let timestamp = dateFormatter.string(from: Date())
            archiveName = "\(baseName).\(timestamp)"

        case let .timestampSequence(format):
            dateFormatter.dateFormat = format
            let timestamp = dateFormatter.string(from: Date())
            archiveName = "\(baseName).\(timestamp).\(sequenceNumber + 1)"

        case let .custom(prefix, suffix):
            archiveName = "\(prefix)\(baseName)\(suffix)"
        }

        let fileName = ext.isEmpty ? archiveName : "\(archiveName).\(ext)"
        return directory.appendingPathComponent(fileName)
    }

    /// Compresses the archived file if configured.
    private func compressIfNeeded(_ archiveURL: URL) -> URL {
        guard configuration.compressionFormat != .none else {
            return archiveURL
        }

        let compressedURL = archiveURL.appendingPathExtension(
            configuration.compressionFormat.rawValue
        )

        // Simple compression implementation
        do {
            let data = try Data(contentsOf: archiveURL)
            let compressedData = compressData(data, format: configuration.compressionFormat)
            try compressedData.write(to: compressedURL)
            try fileManager.removeItem(at: archiveURL)
            return compressedURL
        } catch {
            return archiveURL
        }
    }

    /// Compresses data using the specified format.
    private func compressData(_ data: Data, format: RotationCompressionFormat) -> Data {
        // For production, use Compression framework
        // This is a simplified implementation
        switch format {
        case .gzip, .zip:
            if #available(iOS 13.0, macOS 10.15, *) {
                return (try? (data as NSData).compressed(using: .zlib)) as Data? ?? data
            }
            return data
        case .none:
            return data
        }
    }

    /// Removes old archives beyond the configured limit.
    private func cleanupOldArchives() -> [URL] {
        guard configuration.deleteOldArchives else { return [] }

        var archives = findArchivedFiles()
        var deletedFiles: [URL] = []

        while archives.count > configuration.maxArchivedFiles {
            guard let oldest = archives.first else { break }
            do {
                try fileManager.removeItem(at: oldest)
                deletedFiles.append(oldest)
                archives.removeFirst()
            } catch {
                break
            }
        }

        return deletedFiles
    }

    /// Finds all archived files related to the current log file.
    private func findArchivedFiles() -> [URL] {
        let directory = configuration.archiveDirectory ?? fileURL.deletingLastPathComponent()
        let baseName = fileURL.deletingPathExtension().lastPathComponent

        guard let contents = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else {
            return []
        }

        return contents
            .filter { url in
                let name = url.lastPathComponent
                return name.hasPrefix(baseName) && name != fileURL.lastPathComponent
            }
            .sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 < date2
            }
    }

    /// Returns the size of a file in bytes.
    private func getFileSize(_ url: URL) -> UInt64 {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? UInt64 else {
            return 0
        }
        return size
    }

    /// Loads the sequence number from persistent storage.
    private func loadSequenceNumber() {
        let sequenceFile = fileURL.deletingLastPathComponent()
            .appendingPathComponent(".rotation_sequence")

        if let data = try? Data(contentsOf: sequenceFile),
           let value = String(data: data, encoding: .utf8),
           let number = Int(value) {
            sequenceNumber = number
        }
    }

    /// Saves the sequence number to persistent storage.
    private func saveSequenceNumber() {
        let sequenceFile = fileURL.deletingLastPathComponent()
            .appendingPathComponent(".rotation_sequence")

        try? String(sequenceNumber).write(to: sequenceFile, atomically: true, encoding: .utf8)
    }
}

// MARK: - RotationStatistics

/// Statistics about the rotation manager state.
public struct RotationStatistics: Sendable {

    /// Number of archived files currently stored.
    public let archivedFileCount: Int

    /// Total size of all archived files in bytes.
    public let totalArchivedSize: UInt64

    /// Current size of the active log file.
    public let currentFileSize: UInt64

    /// When the last rotation occurred.
    public let lastRotationTime: Date

    /// Current sequence number.
    public let sequenceNumber: Int

    /// Total size of all log files including current.
    public var totalSize: UInt64 {
        totalArchivedSize + currentFileSize
    }

    /// Human-readable description of total size.
    public var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    }
}

// MARK: - RotatingFileDestination

/// A file destination with built-in rotation support.
///
/// Combines file writing with automatic rotation management.
///
/// ```swift
/// let destination = RotatingFileDestination(
///     fileURL: logsDirectory.appendingPathComponent("app.log"),
///     rotationPolicy: .size(maxBytes: 5_000_000)
/// )
/// logger.addDestination(destination)
/// ```
public final class RotatingFileDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum severity level to write.
    public var minimumLevel: LogLevel = .info

    /// Formatter for log entries.
    public var formatter: LogFormatter = JSONFormatter()

    // MARK: - Properties

    /// The rotation manager handling file rotation.
    public let rotationManager: FileRotationManager

    /// Optional privacy redactor.
    public var redactor: PrivacyRedactor?

    // MARK: - Private

    /// Serial queue for thread-safe file I/O.
    private let queue = DispatchQueue(label: "com.mobilelogger.rotatingfile", qos: .utility)

    /// File handle for writing.
    private var fileHandle: FileHandle?

    /// File manager instance.
    private let fileManager = FileManager.default

    // MARK: - Initialization

    /// Creates a new rotating file destination.
    ///
    /// - Parameters:
    ///   - fileURL: Path to the log file.
    ///   - rotationPolicy: When to rotate files.
    ///   - maxArchivedFiles: Number of archives to keep.
    ///   - compressionFormat: How to compress archives.
    public init(
        fileURL: URL,
        rotationPolicy: FileRotationPolicy = .size(maxBytes: 10_000_000),
        maxArchivedFiles: Int = 5,
        compressionFormat: RotationCompressionFormat = .none
    ) {
        let configuration = FileRotationConfiguration(
            policy: rotationPolicy,
            maxArchivedFiles: maxArchivedFiles,
            compressionFormat: compressionFormat
        )
        self.rotationManager = FileRotationManager(fileURL: fileURL, configuration: configuration)
        openFile()
        rotationManager.startMonitoring()
    }

    deinit {
        rotationManager.stopMonitoring()
        try? fileHandle?.close()
    }

    // MARK: - LogDestination

    /// Writes the log entry to the file.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        queue.async { [self] in
            // Check rotation before writing
            if self.rotationManager.shouldRotate() {
                self.closeFile()
                self.rotationManager.forceRotation()
                self.openFile()
            }

            var output = self.formatter.format(entry)

            if let redactor = self.redactor {
                output = redactor.redact(output)
            }

            let line = output + "\n"

            guard let data = line.data(using: .utf8) else { return }

            self.fileHandle?.write(data)
        }
    }

    // MARK: - Private Methods

    /// Opens the log file for writing.
    private func openFile() {
        queue.async { [self] in
            let directory = self.rotationManager.fileURL.deletingLastPathComponent()
            try? self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

            if !self.fileManager.fileExists(atPath: self.rotationManager.fileURL.path) {
                self.fileManager.createFile(atPath: self.rotationManager.fileURL.path, contents: nil)
            }

            self.fileHandle = try? FileHandle(forWritingTo: self.rotationManager.fileURL)
            self.fileHandle?.seekToEndOfFile()
        }
    }

    /// Closes the file handle.
    private func closeFile() {
        try? fileHandle?.close()
        fileHandle = nil
    }
}
