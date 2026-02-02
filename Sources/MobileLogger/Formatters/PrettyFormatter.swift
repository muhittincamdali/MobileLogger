import Foundation

// MARK: - PrettyFormatter

/// A human-readable formatter that produces clean, scannable log lines.
///
/// Output example:
/// ```
/// 2026-01-15 10:30:00.123 [INFO] User signed in {userId: 42}
/// ```
public struct PrettyFormatter: LogFormatter {

    // MARK: - Configuration

    /// Whether to include metadata in the output. Defaults to `true`.
    public var includeMetadata: Bool

    /// Separator between metadata key-value pairs. Defaults to `", "`.
    public var metadataSeparator: String

    // MARK: - Private

    /// Date formatter for timestamps.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Initialization

    /// Creates a new pretty formatter.
    ///
    /// - Parameters:
    ///   - includeMetadata: Show metadata in output (default `true`).
    ///   - metadataSeparator: Separator for metadata pairs (default `", "`).
    public init(includeMetadata: Bool = true, metadataSeparator: String = ", ") {
        self.includeMetadata = includeMetadata
        self.metadataSeparator = metadataSeparator
    }

    // MARK: - LogFormatter

    /// Formats the entry as a human-readable string.
    ///
    /// - Parameter entry: The log entry to format.
    /// - Returns: A formatted string.
    public func format(_ entry: LogEntry) -> String {
        var parts: [String] = []

        parts.append(entry.message)

        if includeMetadata, let metadata = entry.metadata, !metadata.isEmpty {
            let pairs = metadata
                .sorted { $0.key < $1.key }
                .map { "\($0.key): \($0.value)" }
                .joined(separator: metadataSeparator)
            parts.append("{\(pairs)}")
        }

        return parts.joined(separator: " ")
    }
}
