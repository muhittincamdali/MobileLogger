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
///
/// ## Configuration Options
///
/// Customize the output format using configuration properties:
///
/// ```swift
/// let formatter = JSONFormatter(
///     prettyPrinted: true,
///     includeSourceLocation: true,
///     dateFormat: .iso8601
/// )
/// ```
public struct JSONFormatter: LogFormatter {

    // MARK: - Configuration

    /// Whether to pretty-print the JSON output. Defaults to `false`.
    public var prettyPrinted: Bool

    /// Whether to include source location fields. Defaults to `true`.
    public var includeSourceLocation: Bool

    /// Whether to include the unique entry ID. Defaults to `false`.
    public var includeEntryId: Bool

    /// Whether to escape special Unicode characters. Defaults to `false`.
    public var escapeUnicode: Bool

    /// Whether to include null values for missing optional fields. Defaults to `false`.
    public var includeNullValues: Bool

    /// Whether to flatten nested metadata. Defaults to `false`.
    public var flattenMetadata: Bool

    /// Custom field mappings for output keys.
    public var fieldMappings: JSONFieldMappings

    /// Date formatting style for timestamps.
    public var dateFormat: JSONDateFormat

    /// Additional static fields to include in every log entry.
    public var additionalFields: [String: Any]

    /// Fields to exclude from the output.
    public var excludedFields: Set<String>

    /// Maximum depth for nested objects. Defaults to 10.
    public var maxNestingDepth: Int

    /// Maximum length for string values. Nil for unlimited.
    public var maxStringLength: Int?

    // MARK: - Private

    /// ISO 8601 date formatter shared across invocations.
    private nonisolated(unsafe) let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// Unix timestamp formatter.
    private nonisolated(unsafe) let unixFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Custom date formatter for user-specified formats.
    private nonisolated(unsafe) let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Initialization

    /// Creates a new JSON formatter with default settings.
    public init() {
        self.prettyPrinted = false
        self.includeSourceLocation = true
        self.includeEntryId = false
        self.escapeUnicode = false
        self.includeNullValues = false
        self.flattenMetadata = false
        self.fieldMappings = .default
        self.dateFormat = .iso8601
        self.additionalFields = [:]
        self.excludedFields = []
        self.maxNestingDepth = 10
        self.maxStringLength = nil
    }

    /// Creates a new JSON formatter with custom settings.
    ///
    /// - Parameters:
    ///   - prettyPrinted: Use indented JSON (default `false`).
    ///   - includeSourceLocation: Include file/function/line (default `true`).
    ///   - dateFormat: Timestamp formatting style.
    ///   - fieldMappings: Custom field name mappings.
    public init(
        prettyPrinted: Bool = false,
        includeSourceLocation: Bool = true,
        includeEntryId: Bool = false,
        dateFormat: JSONDateFormat = .iso8601,
        fieldMappings: JSONFieldMappings = .default
    ) {
        self.prettyPrinted = prettyPrinted
        self.includeSourceLocation = includeSourceLocation
        self.includeEntryId = includeEntryId
        self.escapeUnicode = false
        self.includeNullValues = false
        self.flattenMetadata = false
        self.fieldMappings = fieldMappings
        self.dateFormat = dateFormat
        self.additionalFields = [:]
        self.excludedFields = []
        self.maxNestingDepth = 10
        self.maxStringLength = nil
    }

    // MARK: - LogFormatter

    /// Formats the entry as a JSON string.
    ///
    /// - Parameter entry: The log entry to serialize.
    /// - Returns: A JSON-encoded string.
    public func format(_ entry: LogEntry) -> String {
        var dict = buildDictionary(from: entry)

        // Add additional fields
        for (key, value) in additionalFields {
            dict[key] = value
        }

        // Remove excluded fields
        for field in excludedFields {
            dict.removeValue(forKey: field)
        }

        return serialize(dict)
    }

    /// Formats multiple entries as a JSON array.
    ///
    /// - Parameter entries: The log entries to serialize.
    /// - Returns: A JSON array string.
    public func formatBatch(_ entries: [LogEntry]) -> String {
        let dicts = entries.map { buildDictionary(from: $0) }
        return serialize(dicts)
    }

    /// Formats the entry as a single-line NDJSON (newline-delimited JSON).
    ///
    /// - Parameter entry: The log entry to serialize.
    /// - Returns: A compact JSON string without newlines.
    public func formatNDJSON(_ entry: LogEntry) -> String {
        let dict = buildDictionary(from: entry)
        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if #available(iOS 13.0, macOS 10.15, *) {
            options.insert(.withoutEscapingSlashes)
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: options),
              let json = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"serialization_failed\"}"
        }

        return json.replacingOccurrences(of: "\n", with: " ")
    }

    // MARK: - Dictionary Building

    /// Builds the dictionary representation of a log entry.
    private func buildDictionary(from entry: LogEntry) -> [String: Any] {
        var dict: [String: Any] = [:]

        // Timestamp
        dict[fieldMappings.timestamp] = formatDate(entry.timestamp)

        // Level
        dict[fieldMappings.level] = entry.level.description

        // Message
        let message = truncateIfNeeded(entry.message)
        dict[fieldMappings.message] = message

        // Entry ID
        if includeEntryId {
            dict[fieldMappings.entryId] = entry.id.uuidString
        }

        // Metadata
        if let metadata = entry.metadata, !metadata.isEmpty {
            if flattenMetadata {
                for (key, value) in metadata {
                    let flatKey = "\(fieldMappings.metadataPrefix)\(key)"
                    dict[flatKey] = truncateIfNeeded(value)
                }
            } else {
                dict[fieldMappings.metadata] = metadata
            }
        } else if includeNullValues {
            dict[fieldMappings.metadata] = NSNull()
        }

        // Source location
        if includeSourceLocation {
            dict[fieldMappings.file] = entry.fileName
            dict[fieldMappings.function] = entry.function
            dict[fieldMappings.line] = entry.line
        }

        return dict
    }

    /// Formats a date according to the configured format.
    private func formatDate(_ date: Date) -> Any {
        switch dateFormat {
        case .iso8601:
            return iso8601Formatter.string(from: date)

        case .iso8601Basic:
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate]
            return formatter.string(from: date)

        case .unixTimestamp:
            return Int(date.timeIntervalSince1970)

        case .unixTimestampMillis:
            return Int(date.timeIntervalSince1970 * 1000)

        case .unixTimestampDouble:
            return date.timeIntervalSince1970

        case .rfc2822:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: date)

        case .rfc3339:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: date)

        case let .custom(format):
            customFormatter.dateFormat = format
            return customFormatter.string(from: date)
        }
    }

    /// Truncates a string if it exceeds the maximum length.
    private func truncateIfNeeded(_ string: String) -> String {
        guard let maxLength = maxStringLength, string.count > maxLength else {
            return string
        }
        return String(string.prefix(maxLength)) + "..."
    }

    /// Serializes a dictionary to JSON.
    private func serialize(_ object: Any) -> String {
        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if prettyPrinted {
            options.insert(.prettyPrinted)
        }
        if #available(iOS 13.0, macOS 10.15, *) {
            if !escapeUnicode {
                options.insert(.withoutEscapingSlashes)
            }
        }

        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options),
              let json = String(data: data, encoding: .utf8) else {
            return "{\"error\":\"serialization_failed\"}"
        }

        return json
    }
}

// MARK: - JSONDateFormat

/// Date formatting options for JSON output.
public enum JSONDateFormat: Sendable, Equatable {

    /// ISO 8601 format with fractional seconds (default).
    case iso8601

    /// ISO 8601 basic format without fractional seconds.
    case iso8601Basic

    /// Unix timestamp as integer seconds.
    case unixTimestamp

    /// Unix timestamp as integer milliseconds.
    case unixTimestampMillis

    /// Unix timestamp as floating-point seconds.
    case unixTimestampDouble

    /// RFC 2822 format.
    case rfc2822

    /// RFC 3339 format.
    case rfc3339

    /// Custom date format string.
    case custom(String)

    // MARK: - Equatable

    public static func == (lhs: JSONDateFormat, rhs: JSONDateFormat) -> Bool {
        switch (lhs, rhs) {
        case (.iso8601, .iso8601),
             (.iso8601Basic, .iso8601Basic),
             (.unixTimestamp, .unixTimestamp),
             (.unixTimestampMillis, .unixTimestampMillis),
             (.unixTimestampDouble, .unixTimestampDouble),
             (.rfc2822, .rfc2822),
             (.rfc3339, .rfc3339):
            return true
        case let (.custom(l), .custom(r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - JSONFieldMappings

/// Custom field name mappings for JSON output.
///
/// Allows remapping standard field names to match your log aggregation
/// system's expected schema.
///
/// ```swift
/// var mappings = JSONFieldMappings.default
/// mappings.timestamp = "@timestamp"  // Elasticsearch format
/// mappings.level = "severity"        // GCP format
/// ```
public struct JSONFieldMappings: Sendable {

    /// Key for the timestamp field.
    public var timestamp: String

    /// Key for the log level field.
    public var level: String

    /// Key for the message field.
    public var message: String

    /// Key for the metadata field.
    public var metadata: String

    /// Prefix for flattened metadata fields.
    public var metadataPrefix: String

    /// Key for the file field.
    public var file: String

    /// Key for the function field.
    public var function: String

    /// Key for the line number field.
    public var line: String

    /// Key for the entry ID field.
    public var entryId: String

    // MARK: - Presets

    /// Default field mappings.
    public static var `default`: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "timestamp",
            level: "level",
            message: "message",
            metadata: "metadata",
            metadataPrefix: "meta_",
            file: "file",
            function: "function",
            line: "line",
            entryId: "id"
        )
    }

    /// Elasticsearch/ELK-compatible field mappings.
    public static var elasticsearch: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "@timestamp",
            level: "level",
            message: "message",
            metadata: "fields",
            metadataPrefix: "fields.",
            file: "log.file.name",
            function: "log.function",
            line: "log.file.line",
            entryId: "event.id"
        )
    }

    /// Datadog-compatible field mappings.
    public static var datadog: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "timestamp",
            level: "status",
            message: "message",
            metadata: "attributes",
            metadataPrefix: "attr_",
            file: "logger.name",
            function: "logger.method_name",
            line: "logger.line",
            entryId: "dd.trace_id"
        )
    }

    /// Google Cloud Platform-compatible field mappings.
    public static var gcp: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "timestamp",
            level: "severity",
            message: "message",
            metadata: "labels",
            metadataPrefix: "labels.",
            file: "sourceLocation.file",
            function: "sourceLocation.function",
            line: "sourceLocation.line",
            entryId: "insertId"
        )
    }

    /// AWS CloudWatch-compatible field mappings.
    public static var cloudwatch: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "timestamp",
            level: "level",
            message: "message",
            metadata: "context",
            metadataPrefix: "context_",
            file: "source.file",
            function: "source.function",
            line: "source.line",
            entryId: "requestId"
        )
    }

    /// Splunk-compatible field mappings.
    public static var splunk: JSONFieldMappings {
        JSONFieldMappings(
            timestamp: "time",
            level: "level",
            message: "event",
            metadata: "fields",
            metadataPrefix: "",
            file: "source",
            function: "function",
            line: "lineNumber",
            entryId: "eventId"
        )
    }
}

// MARK: - JSONFormatterBuilder

/// A builder for creating customized JSON formatters.
///
/// Provides a fluent API for configuring formatter options.
///
/// ```swift
/// let formatter = JSONFormatterBuilder()
///     .prettyPrinted()
///     .includeSourceLocation()
///     .dateFormat(.unixTimestamp)
///     .addField("app", value: "MyApp")
///     .build()
/// ```
public final class JSONFormatterBuilder {

    /// The formatter being built.
    private var formatter = JSONFormatter()

    // MARK: - Initialization

    /// Creates a new builder with default settings.
    public init() {}

    // MARK: - Builder Methods

    /// Enables pretty-printed output.
    @discardableResult
    public func prettyPrinted(_ enabled: Bool = true) -> JSONFormatterBuilder {
        formatter.prettyPrinted = enabled
        return self
    }

    /// Configures source location inclusion.
    @discardableResult
    public func includeSourceLocation(_ enabled: Bool = true) -> JSONFormatterBuilder {
        formatter.includeSourceLocation = enabled
        return self
    }

    /// Enables entry ID inclusion.
    @discardableResult
    public func includeEntryId(_ enabled: Bool = true) -> JSONFormatterBuilder {
        formatter.includeEntryId = enabled
        return self
    }

    /// Sets the date format.
    @discardableResult
    public func dateFormat(_ format: JSONDateFormat) -> JSONFormatterBuilder {
        formatter.dateFormat = format
        return self
    }

    /// Sets the field mappings.
    @discardableResult
    public func fieldMappings(_ mappings: JSONFieldMappings) -> JSONFormatterBuilder {
        formatter.fieldMappings = mappings
        return self
    }

    /// Adds a static field to all entries.
    @discardableResult
    public func addField(_ key: String, value: Any) -> JSONFormatterBuilder {
        formatter.additionalFields[key] = value
        return self
    }

    /// Excludes a field from the output.
    @discardableResult
    public func excludeField(_ field: String) -> JSONFormatterBuilder {
        formatter.excludedFields.insert(field)
        return self
    }

    /// Enables metadata flattening.
    @discardableResult
    public func flattenMetadata(_ enabled: Bool = true) -> JSONFormatterBuilder {
        formatter.flattenMetadata = enabled
        return self
    }

    /// Enables Unicode escaping.
    @discardableResult
    public func escapeUnicode(_ enabled: Bool = true) -> JSONFormatterBuilder {
        formatter.escapeUnicode = enabled
        return self
    }

    /// Sets the maximum string length.
    @discardableResult
    public func maxStringLength(_ length: Int?) -> JSONFormatterBuilder {
        formatter.maxStringLength = length
        return self
    }

    /// Sets the maximum nesting depth.
    @discardableResult
    public func maxNestingDepth(_ depth: Int) -> JSONFormatterBuilder {
        formatter.maxNestingDepth = depth
        return self
    }

    /// Builds the configured formatter.
    public func build() -> JSONFormatter {
        formatter
    }
}

// MARK: - JSONFormatter Presets

extension JSONFormatter {

    /// Creates a formatter optimized for Elasticsearch ingestion.
    public static var elasticsearch: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .elasticsearch
        formatter.dateFormat = .iso8601
        formatter.includeEntryId = true
        return formatter
    }

    /// Creates a formatter optimized for Datadog ingestion.
    public static var datadog: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .datadog
        formatter.dateFormat = .unixTimestampMillis
        return formatter
    }

    /// Creates a formatter optimized for Google Cloud Logging.
    public static var gcp: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .gcp
        formatter.dateFormat = .iso8601
        return formatter
    }

    /// Creates a formatter optimized for AWS CloudWatch.
    public static var cloudwatch: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .cloudwatch
        formatter.dateFormat = .unixTimestampMillis
        return formatter
    }

    /// Creates a formatter optimized for Splunk.
    public static var splunk: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .splunk
        formatter.dateFormat = .unixTimestamp
        return formatter
    }

    /// Creates a compact formatter with minimal output.
    public static var compact: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.includeSourceLocation = false
        formatter.includeEntryId = false
        formatter.prettyPrinted = false
        return formatter
    }

    /// Creates a verbose formatter with all available fields.
    public static var verbose: JSONFormatter {
        var formatter = JSONFormatter()
        formatter.includeSourceLocation = true
        formatter.includeEntryId = true
        formatter.prettyPrinted = true
        formatter.includeNullValues = true
        return formatter
    }
}

// MARK: - JSONEncodableEntry

/// A Codable wrapper for log entries that supports custom JSON encoding.
public struct JSONEncodableEntry: Codable, Sendable {

    /// The timestamp as a string.
    public let timestamp: String

    /// The log level name.
    public let level: String

    /// The log message.
    public let message: String

    /// Optional metadata dictionary.
    public let metadata: [String: String]?

    /// Source file name.
    public let file: String?

    /// Function name.
    public let function: String?

    /// Line number.
    public let line: UInt?

    /// Entry unique identifier.
    public let id: String?

    // MARK: - Initialization

    /// Creates an encodable entry from a log entry.
    public init(
        from entry: LogEntry,
        includeSourceLocation: Bool = true,
        includeId: Bool = false,
        dateFormatter: ISO8601DateFormatter? = nil
    ) {
        let formatter = dateFormatter ?? {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()

        self.timestamp = formatter.string(from: entry.timestamp)
        self.level = entry.level.description
        self.message = entry.message
        self.metadata = entry.metadata

        if includeSourceLocation {
            self.file = entry.fileName
            self.function = entry.function
            self.line = entry.line
        } else {
            self.file = nil
            self.function = nil
            self.line = nil
        }

        self.id = includeId ? entry.id.uuidString : nil
    }
}

// MARK: - JSONStreamFormatter

/// A formatter that writes JSON entries to a stream format.
///
/// Supports streaming large batches of log entries efficiently.
public final class JSONStreamFormatter: @unchecked Sendable {

    // MARK: - Properties

    /// The underlying JSON formatter.
    public var formatter: JSONFormatter

    /// Separator between entries.
    public var entrySeparator: String

    /// Prefix for the stream.
    public var streamPrefix: String

    /// Suffix for the stream.
    public var streamSuffix: String

    // MARK: - Initialization

    /// Creates a new stream formatter.
    ///
    /// - Parameters:
    ///   - formatter: The JSON formatter to use.
    ///   - style: The stream style.
    public init(formatter: JSONFormatter = JSONFormatter(), style: StreamStyle = .ndjson) {
        self.formatter = formatter

        switch style {
        case .ndjson:
            self.entrySeparator = "\n"
            self.streamPrefix = ""
            self.streamSuffix = ""

        case .jsonArray:
            self.entrySeparator = ",\n"
            self.streamPrefix = "[\n"
            self.streamSuffix = "\n]"

        case .jsonLines:
            self.entrySeparator = "\n"
            self.streamPrefix = ""
            self.streamSuffix = "\n"
        }
    }

    // MARK: - Formatting

    /// Formats a batch of entries as a stream.
    ///
    /// - Parameter entries: The entries to format.
    /// - Returns: The formatted stream string.
    public func format(_ entries: [LogEntry]) -> String {
        var output = streamPrefix

        for (index, entry) in entries.enumerated() {
            output += formatter.format(entry)
            if index < entries.count - 1 {
                output += entrySeparator
            }
        }

        output += streamSuffix
        return output
    }

    /// Stream output styles.
    public enum StreamStyle {
        /// Newline-delimited JSON (one entry per line).
        case ndjson

        /// JSON array format.
        case jsonArray

        /// JSON lines format (similar to NDJSON).
        case jsonLines
    }
}
