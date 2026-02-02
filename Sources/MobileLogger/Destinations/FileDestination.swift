import Foundation

// MARK: - FileDestination

/// A log destination that writes formatted entries to a file on disk.
///
/// Supports automatic file rotation when the log file exceeds a
/// configurable maximum size. Rotated files are named with a numeric
/// suffix (e.g. `app.1.log`, `app.2.log`).
///
/// ```swift
/// let file = FileDestination(
///     fileURL: logsDirectory.appendingPathComponent("app.log"),
///     maxFileSize: 5_000_000,   // 5 MB
///     maxRotatedFiles: 3
/// )
/// logger.addDestination(file)
/// ```
public final class FileDestination: LogDestination, @unchecked Sendable {

    // MARK: - LogDestination

    /// Minimum severity level to write. Defaults to ``LogLevel/info``.
    public var minimumLevel: LogLevel = .info

    /// Formatter used to render entries. Defaults to ``JSONFormatter``.
    public var formatter: LogFormatter = JSONFormatter()

    // MARK: - Configuration

    /// The URL of the active log file.
    public let fileURL: URL

    /// Maximum file size in bytes before rotation occurs.
    public let maxFileSize: UInt64

    /// Number of rotated files to keep. Oldest files beyond this count are deleted.
    public let maxRotatedFiles: Int

    /// Optional redactor for masking PII.
    public var redactor: PrivacyRedactor?

    // MARK: - Private

    /// Serial queue for thread-safe file I/O.
    private let queue = DispatchQueue(label: "com.mobilelogger.file", qos: .utility)

    /// File handle for the active log file.
    private var fileHandle: FileHandle?

    /// Current size of the active log file.
    private var currentFileSize: UInt64 = 0

    /// File manager instance.
    private let fileManager = FileManager.default

    // MARK: - Initialization

    /// Creates a new file destination.
    ///
    /// - Parameters:
    ///   - fileURL: Path to the log file.
    ///   - maxFileSize: Max size in bytes before rotation (default 10 MB).
    ///   - maxRotatedFiles: Number of old files to keep (default 5).
    public init(
        fileURL: URL,
        maxFileSize: UInt64 = 10_000_000,
        maxRotatedFiles: Int = 5
    ) {
        self.fileURL = fileURL
        self.maxFileSize = maxFileSize
        self.maxRotatedFiles = maxRotatedFiles
        openFile()
    }

    deinit {
        try? fileHandle?.close()
    }

    // MARK: - LogDestination

    /// Writes the log entry to the file.
    ///
    /// - Parameter entry: The log entry to persist.
    public func send(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }

        queue.async { [self] in
            var output = self.formatter.format(entry)

            if let redactor = self.redactor {
                output = redactor.redact(output)
            }

            let line = output + "\n"

            guard let data = line.data(using: .utf8) else { return }

            self.write(data)
        }
    }

    // MARK: - File Operations

    /// Opens or creates the log file and prepares the file handle.
    private func openFile() {
        queue.async { [self] in
            let directory = self.fileURL.deletingLastPathComponent()
            try? self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

            if !self.fileManager.fileExists(atPath: self.fileURL.path) {
                self.fileManager.createFile(atPath: self.fileURL.path, contents: nil)
            }

            self.fileHandle = try? FileHandle(forWritingTo: self.fileURL)
            self.fileHandle?.seekToEndOfFile()

            let attributes = try? self.fileManager.attributesOfItem(atPath: self.fileURL.path)
            self.currentFileSize = attributes?[.size] as? UInt64 ?? 0
        }
    }

    /// Writes data to the file, rotating if necessary.
    private func write(_ data: Data) {
        if currentFileSize + UInt64(data.count) > maxFileSize {
            rotateFiles()
        }

        fileHandle?.write(data)
        currentFileSize += UInt64(data.count)
    }

    /// Rotates log files by renaming the current file and removing old ones.
    private func rotateFiles() {
        try? fileHandle?.close()
        fileHandle = nil

        let basePath = fileURL.deletingPathExtension().path
        let ext = fileURL.pathExtension

        // Shift existing rotated files
        for index in stride(from: maxRotatedFiles, through: 1, by: -1) {
            let source = rotatedURL(basePath: basePath, index: index - 1, ext: ext)
            let target = rotatedURL(basePath: basePath, index: index, ext: ext)
            try? fileManager.removeItem(atPath: target)
            try? fileManager.moveItem(atPath: source, toPath: target)
        }

        // Move current file to .1
        let firstRotated = rotatedURL(basePath: basePath, index: 1, ext: ext)
        try? fileManager.moveItem(atPath: fileURL.path, toPath: firstRotated)

        // Remove excess rotated files
        for index in (maxRotatedFiles + 1)...max(maxRotatedFiles + 1, maxRotatedFiles + 5) {
            let old = rotatedURL(basePath: basePath, index: index, ext: ext)
            try? fileManager.removeItem(atPath: old)
        }

        // Create fresh file
        fileManager.createFile(atPath: fileURL.path, contents: nil)
        fileHandle = try? FileHandle(forWritingTo: fileURL)
        currentFileSize = 0
    }

    /// Constructs the path for a rotated file.
    private func rotatedURL(basePath: String, index: Int, ext: String) -> String {
        if ext.isEmpty {
            return "\(basePath).\(index)"
        }
        return "\(basePath).\(index).\(ext)"
    }
}
