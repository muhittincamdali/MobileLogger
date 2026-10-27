import Synchronization

/// Keeps the most recent records in memory, within a count and a byte budget.
///
/// When either limit is reached the oldest records are dropped, so the store never grows past
/// its budget however much the app logs. Use it for an in-app log screen or to export the last
/// few minutes of logs with a bug report:
///
/// ```swift
/// let store = MemoryLogStore(capacity: 2_000)
/// let log = MobileLogger(category: "App", sinks: [OSLogSink(), store])
/// // later
/// let archive = try await LogArchive.make(from: store, format: .text)
/// ```
public final class MemoryLogStore: LogSink, LogRecordSource {
    /// The default of ``capacity``: 1,000 records.
    public static let defaultCapacity = 1_000
    /// The default of ``maximumBytes``: 4 MiB.
    public static let defaultMaximumBytes = 4 * 1_024 * 1_024
    /// The largest ``capacity`` accepted: 100,000 records.
    public static let largestCapacity = 100_000

    /// The most records kept, between 1 and ``largestCapacity``.
    public let capacity: Int
    /// The most bytes kept, by a rough count of each record's size; at least 1 KiB. The newest
    /// record is always kept, even when it alone is larger.
    public let maximumBytes: Int

    private struct State {
        /// Records from `head` on are kept; the ones before it wait to be compacted away.
        var records: [LogRecord] = []
        var sizes: [Int] = []
        var head = 0
        var bytes = 0
        var dropped = 0

        var count: Int { records.count - head }

        mutating func dropOldest() {
            bytes -= sizes[head]
            head += 1
            dropped += 1
            // Compact once the dropped prefix is as long as what is kept: amortised O(1).
            if head >= 64, head >= count {
                records.removeFirst(head)
                sizes.removeFirst(head)
                head = 0
            }
        }
    }

    private let state = Mutex(State())

    /// Creates a store.
    ///
    /// - Parameters:
    ///   - capacity: The most records kept; clamped to 1…``largestCapacity``.
    ///   - maximumBytes: The most bytes kept; at least 1 KiB.
    public init(capacity: Int = defaultCapacity, maximumBytes: Int = defaultMaximumBytes) {
        self.capacity = min(max(capacity, 1), Self.largestCapacity)
        self.maximumBytes = max(maximumBytes, 1_024)
    }

    public func write(_ record: LogRecord) {
        let size = record.estimatedSize
        state.withLock { state in
            if state.count == capacity { state.dropOldest() }
            while state.count > 0, state.bytes + size > maximumBytes { state.dropOldest() }
            state.records.append(record)
            state.sizes.append(size)
            state.bytes += size
        }
    }

    /// The records kept, oldest first.
    public func records() -> [LogRecord] {
        state.withLock { Array($0.records[$0.head...]) }
    }

    /// How many records were dropped to stay within the limits since the store was made or
    /// cleared.
    public var droppedCount: Int {
        state.withLock { $0.dropped }
    }

    /// The rough number of bytes the kept records take.
    public var byteCount: Int {
        state.withLock { $0.bytes }
    }

    /// Removes every record.
    public func removeAll() {
        state.withLock { $0 = State() }
    }
}
