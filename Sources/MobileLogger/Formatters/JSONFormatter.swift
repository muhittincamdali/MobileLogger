import Foundation

// MARK: - JSONFormatter

/// A formatter that serializes log entries as JSON strings.
///
/// Produces machine-readable output suitable for ingestion by log
/// aggregation systems (ELK, Splunk, Datadog, etc.).
///
/// ```swift
/// let formatter = JSONFormatter()
/// let json = formatter.format(entry)
/// // {"timestamp":"2026-01-15T10:30:00Z","level":"info","message":"Hello"}
/// ```
public struct JSONFormatter: LogFormatter {

    // MARK: - Configuration

    /// Whether to pretty-print the JSON output. Defaults to `false`.
    public var prettyPrinted: Bool

    /// Whether to include source location fields. Defaults to `true`.
    public var includeSourceLocation: Bool

    // MARK: - Private

    /// ISO 8601 date formatter shared across invocations.
    private nonisolated(unsafe) let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - Initialization

    /// Creates a new JSON formatter.
    ///
    /// - Parameters:
    ///   - prettyPrinted: Use indented JSON (default `false`).
    ///   - includeSourceLocation: Include file/function/line (default `true`).
    public init(prettyPrinted: Bool = false, includeSourceLocation: Bool = true) {
        self.prettyPrinted = prettyPrinted
        self.includeSourceLocation = includeSourceLocation
    }

    // MARK: - LogFormatter

    /// Formats the entry as a JSON string.
    ///
    /// - Parameter entry: The log entry to serialize.
    /// - Returns: A JSON-encoded string.
    public func format(_ entry: LogEntry) -> String {
        var dict: [String: Any] = [
            "timestamp": dateFormatter.string(from: entry.timestamp),
            "level": entry.level.description,
            "message": entry.message
        ]

        if let metadata = entry.metadata, !metadata.isEmpty {
            dict["metadata"] = metadata
        }

        if includeSourceLocation {
            dict["file"] = entry.fileName
            dict["function"] = entry.function
            dict["line"] = entry.line
        }

        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if prettyPrinted {
            options.insert(.prettyPrinted)
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: options),
              let json = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"serialization_failed\",\"message\":\"\(entry.message)\"}"
        }

        return json
    }
}
