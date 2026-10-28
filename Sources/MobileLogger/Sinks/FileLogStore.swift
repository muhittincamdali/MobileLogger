import Foundation
import Synchronization

/// Keeps records on disk as JSON Lines, in a fixed number of files of a fixed size.
///
/// The newest records are in `log.jsonl`; when it is full it becomes `log.1.jsonl`, the older
/// files move up by one and the oldest is deleted, so the store never takes more than
/// ``maximumFileSize`` × ``maximumFileCount`` bytes. Records are written on a background queue;
/// when the disk falls behind, records beyond ``pendingLimit`` bytes are dropped and counted
/// instead of piling up in memory.
///
/// What reaches the disk is already redacted. On iOS, tvOS, watchOS and visionOS the files are
/// created with `completeUntilFirstUserAuthentication` data protection.
///
/// ```swift
/// let store = FileLogStore()   // Library/Caches/MobileLogger
/// let log = MobileLogger(category: "Sync", sinks: [OSLogSink(), store])
/// // later, for a bug report
/// let records = try await store.records()
/// ```
public final class FileLogStore: LogSink, LogRecordSource {
    /// `Library/Caches/MobileLogger`: the system may purge it when space runs low, and it is
    /// not backed up.
    public static var defaultDirectory: URL {
        URL.cachesDirectory.appending(path: "MobileLogger", directoryHint: .isDirectory)
    }

    /// The default of ``maximumFileSize``: 1 MiB.
    public static let defaultMaximumFileSize = 1_024 * 1_024
    /// The default of ``maximumFileCount``: 4 files.
    public static let defaultMaximumFileCount = 4
    /// The accepted range of ``maximumFileSize``: 64 KiB to 64 MiB.
    public static let fileSizeRange = (64 * 1_024)...(64 * 1_024 * 1_024)
    /// The accepted range of ``maximumFileCount``.
    public static let fileCountRange = 1...32
    /// The default of ``pendingLimit``: 1 MiB.
    public static let defaultPendingLimit = 1_024 * 1_024

    /// The folder of the log files.
    public let directory: URL
    /// The largest size of one file, in bytes; a record that alone is larger is dropped.
    public let maximumFileSize: Int
    /// How many files are kept.
    public let maximumFileCount: Int
    /// How many bytes may wait for the disk before new records are dropped.
    public let pendingLimit: Int

    private struct Counters {
        var pendingBytes = 0
        var dropped = 0
        var writeFailures = 0
    }

    private struct Writer {
        var handle: FileHandle?
        var size = 0
    }

    private let counters = Mutex(Counters())
    /// Only used on `queue`; the lock is never contended.
    private let writer = Mutex(Writer())
    private let queue = DispatchQueue(label: "MobileLogger.FileLogStore", qos: .utility)

    /// Creates a store.
    ///
    /// - Parameters:
    ///   - directory: The folder of the log files; created when the first record is written.
    ///   - maximumFileSize: The largest size of one file, clamped to ``fileSizeRange``.
    ///   - maximumFileCount: How many files are kept, clamped to ``fileCountRange``.
    ///   - pendingLimit: How many bytes may wait for the disk; at least ``maximumFileSize``.
    public init(
        directory: URL = FileLogStore.defaultDirectory, maximumFileSize: Int = defaultMaximumFileSize,
        maximumFileCount: Int = defaultMaximumFileCount, pendingLimit: Int = defaultPendingLimit
    ) {
        self.directory = directory
        let fileSize = min(max(maximumFileSize, Self.fileSizeRange.lowerBound), Self.fileSizeRange.upperBound)
        self.maximumFileSize = fileSize
        self.maximumFileCount = min(max(maximumFileCount, Self.fileCountRange.lowerBound), Self.fileCountRange.upperBound)
        self.pendingLimit = max(pendingLimit, fileSize)
    }

    deinit {
        writer.withLock { try? $0.handle?.close() }
    }

    public func write(_ record: LogRecord) {
        guard let line = try? LogFormat.jsonLine(record), line.count <= maximumFileSize else {
            counters.withLock { $0.dropped += 1 }
            return
        }
        let accepted = counters.withLock { counters in
            guard counters.pendingBytes + line.count <= pendingLimit else {
                counters.dropped += 1
                return false
            }
            counters.pendingBytes += line.count
            return true
        }
        guard accepted else { return }
        queue.async { [self] in
            let written = append(line)
            counters.withLock { counters in
                counters.pendingBytes -= line.count
                if !written { counters.writeFailures += 1 }
            }
        }
    }

    /// The records in the files, oldest first, after every record written before the call.
    ///
    /// A line that does not decode is skipped, and so is a file larger than twice
    /// ``maximumFileSize``, which this store never writes.
    public func records() async -> [LogRecord] {
        await onQueue { [self] in
            fileURLs().reversed().flatMap { readRecords(at: $0) }
        }
    }

    /// Waits until every record written before the call is on disk.
    public func flush() async {
        await onQueue { [self] in
            writer.withLock { try? $0.handle?.synchronize() }
        }
    }

    /// Deletes every log file.
    public func removeAll() async {
        await onQueue { [self] in
            writer.withLock { writer in
                try? writer.handle?.close()
                writer = Writer()
            }
            for url in fileURLs() { try? FileManager.default.removeItem(at: url) }
        }
    }

    /// How many records were dropped: larger than a file, or written while the disk was behind.
    public var droppedCount: Int {
        counters.withLock { $0.dropped }
    }

    /// How many records could not be written because of a file system error.
    public var writeFailureCount: Int {
        counters.withLock { $0.writeFailures }
    }

    // MARK: - Files

    /// `log.jsonl`, `log.1.jsonl` … newest first.
    func fileURLs() -> [URL] {
        (0..<maximumFileCount).map { fileURL(index: $0) }
    }

    private func fileURL(index: Int) -> URL {
        directory.appending(path: index == 0 ? "log.jsonl" : "log.\(index).jsonl", directoryHint: .notDirectory)
    }

    private func onQueue<Value: Sendable>(_ work: @escaping @Sendable () -> Value) async -> Value {
        await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: work()) }
        }
    }

    /// Appends one line, rotating first when it does not fit. Runs on `queue`.
    private func append(_ line: Data) -> Bool {
        writer.withLock { writer in
            do {
                if writer.handle == nil { try open(&writer) }
                if writer.size > 0, writer.size + line.count > maximumFileSize {
                    try? writer.handle?.close()
                    writer = Writer()
                    rotate()
                    try open(&writer)
                }
                try writer.handle?.write(contentsOf: line)
                writer.size += line.count
                return true
            } catch {
                try? writer.handle?.close()
                writer = Writer()
                return false
            }
        }
    }

    private func open(_ writer: inout Writer) throws {
        let manager = FileManager.default
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = fileURL(index: 0)
        if !manager.fileExists(atPath: url.path(percentEncoded: false)) {
            #if os(macOS)
            let attributes: [FileAttributeKey: Any]? = nil
            #else
            let attributes: [FileAttributeKey: Any]? = [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            #endif
            guard manager.createFile(atPath: url.path(percentEncoded: false), contents: nil, attributes: attributes) else {
                throw CocoaError(.fileWriteUnknown)
            }
        }
        let handle = try FileHandle(forWritingTo: url)
        writer.size = Int(clamping: try handle.seekToEnd())
        writer.handle = handle
    }

    /// Moves every file up by one and deletes the oldest. Runs on `queue`.
    private func rotate() {
        let manager = FileManager.default
        let urls = fileURLs()
        try? manager.removeItem(at: urls[urls.count - 1])
        for index in stride(from: urls.count - 2, through: 0, by: -1) {
            try? manager.moveItem(at: urls[index], to: urls[index + 1])
        }
    }

    private func readRecords(at url: URL) -> [LogRecord] {
        let path = url.path(percentEncoded: false)
        guard let size = (try? FileManager.default.attributesOfItem(atPath: path))?[.size] as? Int,
              size <= maximumFileSize * 2,
              let data = FileManager.default.contents(atPath: path)
        else { return [] }
        let decoder = JSONDecoder()
        return data.split(separator: UInt8(ascii: "\n")).compactMap { try? decoder.decode(LogRecord.self, from: Data($0)) }
    }
}
