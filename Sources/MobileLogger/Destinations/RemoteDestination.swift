import Foundation

// MARK: - RemoteDestination

/// A log destination that ships log entries to a remote HTTP endpoint.
///
/// Entries are batched in memory and flushed either when the batch
/// reaches ``batchSize`` or when ``flushInterval`` seconds elapse —
/// whichever comes first.
///
/// ```swift
/// let remote = RemoteDestination(
///     endpointURL: URL(string: "https://logs.example.com/ingest")!,
///     batchSize: 25,
///     flushInterval: 60
/// )
/// logger.addDestination(remote)
/// ```
public final class RemoteDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum severity level. Defaults to ``LogLevel/warning``.
    public var minimumLevel: LogLevel = .warning

    /// Formatter used to serialize entries. Defaults to ``JSONFormatter``.
    public var formatter: LogFormatter = JSONFormatter()

    // MARK: - Configuration

    /// The remote endpoint URL that accepts `POST` requests.
    public let endpointURL: URL

    /// Number of entries to collect before flushing.
    public let batchSize: Int

    /// Maximum time in seconds between automatic flushes.
    public let flushInterval: TimeInterval

    /// Optional HTTP headers added to every request (e.g. auth tokens).
    public var additionalHeaders: [String: String] = [:]

    // MARK: - Private

    /// Pending log entries waiting to be flushed.
    private var pendingEntries: [String] = []

    /// Serial queue for thread safety.
    private let queue = DispatchQueue(label: "com.mobilelogger.remote", qos: .utility)

    /// URL session for network requests.
    private let session: URLSession

    /// Timer that triggers periodic flushes.
    private var flushTimer: DispatchSourceTimer?

    // MARK: - Initialization

    /// Creates a new remote destination.
    ///
    /// - Parameters:
    ///   - endpointURL: The URL to POST batches to.
    ///   - batchSize: Flush after this many entries (default 10).
    ///   - flushInterval: Flush after this many seconds (default 30).
    ///   - session: URL session to use (default `.shared`).
    public init(
        endpointURL: URL,
        batchSize: Int = 10,
        flushInterval: TimeInterval = 30,
        session: URLSession = .shared
    ) {
        self.endpointURL = endpointURL
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        self.session = session
        startFlushTimer()
    }

    deinit {
        flushTimer?.cancel()
    }

    // MARK: - LogDestination

    /// Enqueues a log entry for batched delivery.
    ///
    /// - Parameter entry: The log entry to ship.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        let formatted = formatter.format(entry)

        queue.async { [weak self] in
            guard let self else { return }
            self.pendingEntries.append(formatted)

            if self.pendingEntries.count >= self.batchSize {
                self.flush()
            }
        }
    }

    // MARK: - Flush

    /// Immediately flushes all pending entries to the remote endpoint.
    public func flush() {
        queue.async { [weak self] in
            guard let self, !self.pendingEntries.isEmpty else { return }

            let batch = self.pendingEntries
            self.pendingEntries.removeAll()

            self.sendBatch(batch)
        }
    }

    // MARK: - Private

    /// Posts a batch of formatted log strings to the endpoint.
    private func sendBatch(_ entries: [String]) {
        let payload = "[\(entries.joined(separator: ","))]"

        guard let body = payload.data(using: .utf8) else { return }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = body

        let task = session.dataTask(with: request) { _, response, error in
            if let error {
                debugPrint("[MobileLogger] Remote flush failed: \(error.localizedDescription)")
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                debugPrint("[MobileLogger] Remote endpoint returned status \(http.statusCode)")
            }
        }
        task.resume()
    }

    /// Starts the periodic flush timer.
    private func startFlushTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(
            deadline: .now() + flushInterval,
            repeating: flushInterval,
            leeway: .seconds(1)
        )
        timer.setEventHandler { [weak self] in
            self?.flush()
        }
        timer.resume()
        flushTimer = timer
    }
}
