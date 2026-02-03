import Foundation
#if canImport(Compression)
import Compression
#endif

// MARK: - ExportFormat

/// Supported log export formats.
///
/// Different formats are suited for different use cases:
/// - JSON for machine processing
/// - CSV for spreadsheet analysis
/// - Plain text for human reading
public enum ExportFormat: String, Sendable, CaseIterable {

    /// JSON format with full metadata.
    case json

    /// JSON Lines format (one JSON object per line).
    case jsonLines

    /// Comma-separated values.
    case csv

    /// Tab-separated values.
    case tsv

    /// Plain text format.
    case plainText

    /// XML format.
    case xml

    /// HTML format with styling.
    case html

    /// Markdown format.
    case markdown

    /// Apple System Log format.
    case asl

    /// Syslog format (RFC 5424).
    case syslog

    /// File extension for this format.
    public var fileExtension: String {
        switch self {
        case .json, .jsonLines:
            return "json"
        case .csv:
            return "csv"
        case .tsv:
            return "tsv"
        case .plainText:
            return "txt"
        case .xml:
            return "xml"
        case .html:
            return "html"
        case .markdown:
            return "md"
        case .asl:
            return "asl"
        case .syslog:
            return "log"
        }
    }

    /// MIME type for this format.
    public var mimeType: String {
        switch self {
        case .json, .jsonLines:
            return "application/json"
        case .csv:
            return "text/csv"
        case .tsv:
            return "text/tab-separated-values"
        case .plainText:
            return "text/plain"
        case .xml:
            return "application/xml"
        case .html:
            return "text/html"
        case .markdown:
            return "text/markdown"
        case .asl, .syslog:
            return "text/plain"
        }
    }
}

// MARK: - CompressionType

/// Supported compression algorithms for exported logs.
public enum CompressionType: String, Sendable, CaseIterable {

    /// No compression.
    case none

    /// Gzip compression.
    case gzip

    /// Zlib compression.
    case zlib

    /// LZMA compression.
    case lzma

    /// LZ4 compression (fastest).
    case lz4

    /// File extension suffix for compressed files.
    public var fileExtensionSuffix: String {
        switch self {
        case .none:
            return ""
        case .gzip:
            return ".gz"
        case .zlib:
            return ".z"
        case .lzma:
            return ".lzma"
        case .lz4:
            return ".lz4"
        }
    }
}

// MARK: - ExportOptions

/// Configuration options for log export.
///
/// Customize the export process including format, filtering,
/// and output options.
///
/// ```swift
/// var options = ExportOptions()
/// options.format = .json
/// options.compression = .gzip
/// options.includeMetadata = true
/// options.dateRange = lastWeek...Date()
/// ```
public struct ExportOptions: Sendable {

    /// The export format to use.
    public var format: ExportFormat

    /// Compression to apply to the output.
    public var compression: CompressionType

    /// Whether to include log metadata.
    public var includeMetadata: Bool

    /// Whether to include timestamps.
    public var includeTimestamps: Bool

    /// Whether to include log levels.
    public var includeLevels: Bool

    /// Whether to include source file information.
    public var includeSourceInfo: Bool

    /// Whether to include thread information.
    public var includeThreadInfo: Bool

    /// Date range filter (nil for all logs).
    public var dateRange: ClosedRange<Date>?

    /// Minimum log level to include.
    public var minimumLevel: LogLevel?

    /// Maximum number of entries to export (nil for unlimited).
    public var maxEntries: Int?

    /// Categories to include (nil for all).
    public var categories: Set<String>?

    /// Categories to exclude.
    public var excludeCategories: Set<String>

    /// Text to search for (case-insensitive).
    public var searchText: String?

    /// Date format for timestamps.
    public var dateFormat: String

    /// Timezone for date formatting.
    public var timezone: TimeZone

    /// Field separator for delimited formats.
    public var fieldSeparator: String

    /// Line separator.
    public var lineSeparator: String

    /// Whether to include a header row (CSV/TSV).
    public var includeHeader: Bool

    /// Custom fields to include in export.
    public var customFields: [String]

    /// Whether to pretty-print JSON output.
    public var prettyPrint: Bool

    /// Encoding for text output.
    public var encoding: String.Encoding

    /// Creates export options with default values.
    public init() {
        self.format = .json
        self.compression = .none
        self.includeMetadata = true
        self.includeTimestamps = true
        self.includeLevels = true
        self.includeSourceInfo = false
        self.includeThreadInfo = false
        self.dateRange = nil
        self.minimumLevel = nil
        self.maxEntries = nil
        self.categories = nil
        self.excludeCategories = []
        self.searchText = nil
        self.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        self.timezone = .current
        self.fieldSeparator = ","
        self.lineSeparator = "\n"
        self.includeHeader = true
        self.customFields = []
        self.prettyPrint = false
        self.encoding = .utf8
    }
}

// MARK: - ExportResult

/// Result of a log export operation.
public struct ExportResult: Sendable {

    /// Whether the export succeeded.
    public let success: Bool

    /// Path to the exported file (if saved to disk).
    public let filePath: URL?

    /// The exported data (if in-memory export).
    public let data: Data?

    /// Number of log entries exported.
    public let entryCount: Int

    /// Size of the exported data in bytes.
    public let byteCount: Int

    /// Size after compression (if compressed).
    public let compressedByteCount: Int?

    /// Time taken to export in seconds.
    public let duration: TimeInterval

    /// Any error that occurred.
    public let error: Error?

    /// Export format used.
    public let format: ExportFormat

    /// Compression used.
    public let compression: CompressionType

    /// Creates an export result.
    public init(
        success: Bool,
        filePath: URL? = nil,
        data: Data? = nil,
        entryCount: Int = 0,
        byteCount: Int = 0,
        compressedByteCount: Int? = nil,
        duration: TimeInterval = 0,
        error: Error? = nil,
        format: ExportFormat = .json,
        compression: CompressionType = .none
    ) {
        self.success = success
        self.filePath = filePath
        self.data = data
        self.entryCount = entryCount
        self.byteCount = byteCount
        self.compressedByteCount = compressedByteCount
        self.duration = duration
        self.error = error
        self.format = format
        self.compression = compression
    }
}

// MARK: - ExportError

/// Errors that can occur during log export.
public enum ExportError: Error, LocalizedError, Sendable {

    /// No logs available to export.
    case noLogsAvailable

    /// The specified format is not supported.
    case unsupportedFormat(ExportFormat)

    /// Failed to create the output file.
    case fileCreationFailed(URL)

    /// Failed to write to the output file.
    case writeError(Error)

    /// Compression failed.
    case compressionFailed(Error)

    /// Encoding failed.
    case encodingFailed

    /// Export was cancelled.
    case cancelled

    /// Invalid date range specified.
    case invalidDateRange

    /// Export timed out.
    case timeout

    public var errorDescription: String? {
        switch self {
        case .noLogsAvailable:
            return "No log entries available to export"
        case .unsupportedFormat(let format):
            return "Export format '\(format.rawValue)' is not supported"
        case .fileCreationFailed(let url):
            return "Failed to create output file at \(url.path)"
        case .writeError(let error):
            return "Failed to write export data: \(error.localizedDescription)"
        case .compressionFailed(let error):
            return "Compression failed: \(error.localizedDescription)"
        case .encodingFailed:
            return "Failed to encode log data"
        case .cancelled:
            return "Export was cancelled"
        case .invalidDateRange:
            return "Invalid date range specified"
        case .timeout:
            return "Export operation timed out"
        }
    }
}

// MARK: - ExportProgressDelegate

/// Delegate protocol for export progress updates.
public protocol ExportProgressDelegate: AnyObject {

    /// Called when export progress updates.
    ///
    /// - Parameters:
    ///   - exporter: The exporter instance.
    ///   - progress: Progress from 0.0 to 1.0.
    ///   - processedCount: Number of entries processed.
    ///   - totalCount: Total number of entries.
    func logExporter(
        _ exporter: LogExporter,
        didUpdateProgress progress: Double,
        processedCount: Int,
        totalCount: Int
    )

    /// Called when export completes.
    ///
    /// - Parameters:
    ///   - exporter: The exporter instance.
    ///   - result: The export result.
    func logExporter(_ exporter: LogExporter, didCompleteWithResult result: ExportResult)
}

// MARK: - Default Delegate Implementation

extension ExportProgressDelegate {

    public func logExporter(
        _ exporter: LogExporter,
        didUpdateProgress progress: Double,
        processedCount: Int,
        totalCount: Int
    ) {}

    public func logExporter(_ exporter: LogExporter, didCompleteWithResult result: ExportResult) {}
}

// MARK: - LogExporter

/// Exports log entries to various formats.
///
/// LogExporter provides comprehensive log export functionality with support
/// for multiple formats, compression, filtering, and streaming exports.
///
/// ## Basic Usage
///
/// ```swift
/// let exporter = LogExporter(logger: Logger.shared)
/// let result = try await exporter.export(to: documentsURL, options: .init())
/// ```
///
/// ## Filtering
///
/// ```swift
/// var options = ExportOptions()
/// options.minimumLevel = .warning
/// options.dateRange = yesterday...Date()
/// let result = try await exporter.export(options: options)
/// ```
///
/// ## Compression
///
/// ```swift
/// var options = ExportOptions()
/// options.compression = .gzip
/// let result = try await exporter.exportToFile(url: archiveURL, options: options)
/// ```
public final class LogExporter: @unchecked Sendable {

    // MARK: - Properties

    /// The logger to export from.
    public let logger: Logger

    /// Progress delegate.
    public weak var delegate: ExportProgressDelegate?

    /// Whether an export is currently in progress.
    public private(set) var isExporting: Bool = false

    /// Serial queue for thread-safe operations.
    private let queue = DispatchQueue(label: "com.mobilelogger.exporter")

    /// Date formatter for timestamps.
    private let dateFormatter: DateFormatter

    /// ISO 8601 formatter for JSON.
    private let isoFormatter: ISO8601DateFormatter

    /// Cancellation flag.
    private var isCancelled: Bool = false

    // MARK: - Initialization

    /// Creates a new log exporter.
    ///
    /// - Parameter logger: The logger to export from.
    public init(logger: Logger = Logger.shared) {
        self.logger = logger
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        self.isoFormatter = ISO8601DateFormatter()
        self.isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    // MARK: - Export Methods

    /// Exports logs to data.
    ///
    /// - Parameter options: Export options.
    /// - Returns: The export result.
    public func exportToData(options: ExportOptions = ExportOptions()) async throws -> ExportResult {
        let startTime = Date()
        isCancelled = false
        isExporting = true

        defer { isExporting = false }

        let entries = filterEntries(logger.recentEntries(), options: options)

        guard !entries.isEmpty else {
            throw ExportError.noLogsAvailable
        }

        let data = try formatEntries(entries, options: options)

        let finalData: Data
        let compressedSize: Int?

        if options.compression != .none {
            finalData = try compressData(data, compression: options.compression)
            compressedSize = finalData.count
        } else {
            finalData = data
            compressedSize = nil
        }

        let duration = Date().timeIntervalSince(startTime)

        let result = ExportResult(
            success: true,
            data: finalData,
            entryCount: entries.count,
            byteCount: data.count,
            compressedByteCount: compressedSize,
            duration: duration,
            format: options.format,
            compression: options.compression
        )

        delegate?.logExporter(self, didCompleteWithResult: result)
        return result
    }

    /// Exports logs to a file.
    ///
    /// - Parameters:
    ///   - url: Destination file URL.
    ///   - options: Export options.
    /// - Returns: The export result.
    public func exportToFile(
        url: URL,
        options: ExportOptions = ExportOptions()
    ) async throws -> ExportResult {
        let startTime = Date()
        isCancelled = false
        isExporting = true

        defer { isExporting = false }

        let entries = filterEntries(logger.recentEntries(), options: options)

        guard !entries.isEmpty else {
            throw ExportError.noLogsAvailable
        }

        let data = try formatEntries(entries, options: options)

        let finalData: Data
        let compressedSize: Int?
        var finalURL = url

        if options.compression != .none {
            finalData = try compressData(data, compression: options.compression)
            compressedSize = finalData.count

            if !url.path.hasSuffix(options.compression.fileExtensionSuffix) {
                finalURL = url.appendingPathExtension(
                    String(options.compression.fileExtensionSuffix.dropFirst())
                )
            }
        } else {
            finalData = data
            compressedSize = nil
        }

        do {
            try finalData.write(to: finalURL)
        } catch {
            throw ExportError.writeError(error)
        }

        let duration = Date().timeIntervalSince(startTime)

        let result = ExportResult(
            success: true,
            filePath: finalURL,
            entryCount: entries.count,
            byteCount: data.count,
            compressedByteCount: compressedSize,
            duration: duration,
            format: options.format,
            compression: options.compression
        )

        delegate?.logExporter(self, didCompleteWithResult: result)
        return result
    }

    /// Exports logs as a string.
    ///
    /// - Parameter options: Export options.
    /// - Returns: The formatted log string.
    public func exportToString(options: ExportOptions = ExportOptions()) throws -> String {
        let entries = filterEntries(logger.recentEntries(), options: options)

        guard !entries.isEmpty else {
            throw ExportError.noLogsAvailable
        }

        let data = try formatEntries(entries, options: options)

        guard let string = String(data: data, encoding: options.encoding) else {
            throw ExportError.encodingFailed
        }

        return string
    }

    /// Cancels an in-progress export.
    public func cancel() {
        isCancelled = true
    }

    // MARK: - Filtering

    private func filterEntries(_ entries: [LogEntry], options: ExportOptions) -> [LogEntry] {
        var filtered = entries

        if let dateRange = options.dateRange {
            filtered = filtered.filter { dateRange.contains($0.timestamp) }
        }

        if let minLevel = options.minimumLevel {
            filtered = filtered.filter { $0.level >= minLevel }
        }

        if let categories = options.categories, !categories.isEmpty {
            filtered = filtered.filter { entry in
                guard let category = entry.category else { return false }
                return categories.contains(category)
            }
        }

        if !options.excludeCategories.isEmpty {
            filtered = filtered.filter { entry in
                guard let category = entry.category else { return true }
                return !options.excludeCategories.contains(category)
            }
        }

        if let searchText = options.searchText, !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            filtered = filtered.filter { entry in
                entry.message.lowercased().contains(lowercased)
            }
        }

        if let maxEntries = options.maxEntries {
            filtered = Array(filtered.prefix(maxEntries))
        }

        return filtered
    }

    // MARK: - Formatting

    private func formatEntries(_ entries: [LogEntry], options: ExportOptions) throws -> Data {
        dateFormatter.dateFormat = options.dateFormat
        dateFormatter.timeZone = options.timezone

        switch options.format {
        case .json:
            return try formatAsJSON(entries, options: options)
        case .jsonLines:
            return try formatAsJSONLines(entries, options: options)
        case .csv:
            return formatAsCSV(entries, options: options)
        case .tsv:
            var tsvOptions = options
            tsvOptions.fieldSeparator = "\t"
            return formatAsCSV(entries, options: tsvOptions)
        case .plainText:
            return formatAsPlainText(entries, options: options)
        case .xml:
            return formatAsXML(entries, options: options)
        case .html:
            return formatAsHTML(entries, options: options)
        case .markdown:
            return formatAsMarkdown(entries, options: options)
        case .asl:
            return formatAsASL(entries, options: options)
        case .syslog:
            return formatAsSyslog(entries, options: options)
        }
    }

    private func formatAsJSON(_ entries: [LogEntry], options: ExportOptions) throws -> Data {
        let exportData = entries.map { entry -> [String: Any] in
            var dict: [String: Any] = [
                "message": entry.message
            ]

            if options.includeTimestamps {
                dict["timestamp"] = isoFormatter.string(from: entry.timestamp)
            }

            if options.includeLevels {
                dict["level"] = entry.level.rawValue
            }

            if options.includeMetadata, let metadata = entry.metadata {
                dict["metadata"] = metadata
            }

            if options.includeSourceInfo {
                if let file = entry.file {
                    dict["file"] = file
                }
                if let function = entry.function {
                    dict["function"] = function
                }
                if let line = entry.line {
                    dict["line"] = line
                }
            }

            if let category = entry.category {
                dict["category"] = category
            }

            return dict
        }

        var jsonOptions: JSONSerialization.WritingOptions = [.sortedKeys]
        if options.prettyPrint {
            jsonOptions.insert(.prettyPrinted)
        }

        return try JSONSerialization.data(withJSONObject: exportData, options: jsonOptions)
    }

    private func formatAsJSONLines(_ entries: [LogEntry], options: ExportOptions) throws -> Data {
        var lines: [String] = []

        for entry in entries {
            var dict: [String: Any] = [
                "message": entry.message
            ]

            if options.includeTimestamps {
                dict["timestamp"] = isoFormatter.string(from: entry.timestamp)
            }

            if options.includeLevels {
                dict["level"] = entry.level.rawValue
            }

            if options.includeMetadata, let metadata = entry.metadata {
                dict["metadata"] = metadata
            }

            if let category = entry.category {
                dict["category"] = category
            }

            let lineData = try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
            if let lineString = String(data: lineData, encoding: .utf8) {
                lines.append(lineString)
            }
        }

        let output = lines.joined(separator: options.lineSeparator)
        return output.data(using: options.encoding) ?? Data()
    }

    private func formatAsCSV(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var lines: [String] = []
        let separator = options.fieldSeparator

        if options.includeHeader {
            var headers: [String] = []
            if options.includeTimestamps {
                headers.append("Timestamp")
            }
            if options.includeLevels {
                headers.append("Level")
            }
            headers.append("Message")
            if options.includeSourceInfo {
                headers.append("File")
                headers.append("Function")
                headers.append("Line")
            }
            lines.append(headers.joined(separator: separator))
        }

        for entry in entries {
            var fields: [String] = []

            if options.includeTimestamps {
                fields.append(escapeCSVField(dateFormatter.string(from: entry.timestamp), separator: separator))
            }

            if options.includeLevels {
                fields.append(entry.level.rawValue)
            }

            fields.append(escapeCSVField(entry.message, separator: separator))

            if options.includeSourceInfo {
                fields.append(escapeCSVField(entry.file ?? "", separator: separator))
                fields.append(escapeCSVField(entry.function ?? "", separator: separator))
                fields.append(entry.line.map { String($0) } ?? "")
            }

            lines.append(fields.joined(separator: separator))
        }

        let output = lines.joined(separator: options.lineSeparator)
        return output.data(using: options.encoding) ?? Data()
    }

    private func escapeCSVField(_ field: String, separator: String) -> String {
        let needsQuoting = field.contains(separator) ||
                          field.contains("\"") ||
                          field.contains("\n") ||
                          field.contains("\r")

        if needsQuoting {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }

        return field
    }

    private func formatAsPlainText(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var lines: [String] = []

        for entry in entries {
            var line = ""

            if options.includeTimestamps {
                line += "[\(dateFormatter.string(from: entry.timestamp))] "
            }

            if options.includeLevels {
                line += "[\(entry.level.rawValue.uppercased())] "
            }

            line += entry.message

            if options.includeSourceInfo {
                if let file = entry.file, let line = entry.line {
                    line += " (\(file):\(line))"
                }
            }

            lines.append(line)
        }

        let output = lines.joined(separator: options.lineSeparator)
        return output.data(using: options.encoding) ?? Data()
    }

    private func formatAsXML(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<logs>\n"

        for entry in entries {
            xml += "  <entry>\n"

            if options.includeTimestamps {
                xml += "    <timestamp>\(escapeXML(isoFormatter.string(from: entry.timestamp)))</timestamp>\n"
            }

            if options.includeLevels {
                xml += "    <level>\(escapeXML(entry.level.rawValue))</level>\n"
            }

            xml += "    <message>\(escapeXML(entry.message))</message>\n"

            if let category = entry.category {
                xml += "    <category>\(escapeXML(category))</category>\n"
            }

            if options.includeSourceInfo {
                if let file = entry.file {
                    xml += "    <file>\(escapeXML(file))</file>\n"
                }
                if let function = entry.function {
                    xml += "    <function>\(escapeXML(function))</function>\n"
                }
                if let line = entry.line {
                    xml += "    <line>\(line)</line>\n"
                }
            }

            if options.includeMetadata, let metadata = entry.metadata, !metadata.isEmpty {
                xml += "    <metadata>\n"
                for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
                    xml += "      <\(escapeXML(key))>\(escapeXML(value))</\(escapeXML(key))>\n"
                }
                xml += "    </metadata>\n"
            }

            xml += "  </entry>\n"
        }

        xml += "</logs>\n"
        return xml.data(using: options.encoding) ?? Data()
    }

    private func escapeXML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private func formatAsHTML(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Log Export</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #4a90d9; color: white; }
                tr:nth-child(even) { background-color: #f9f9f9; }
                tr:hover { background-color: #f1f1f1; }
                .trace { color: #888; }
                .debug { color: #666; }
                .info { color: #333; }
                .notice { color: #0066cc; }
                .warning { color: #ff9900; }
                .error { color: #cc0000; }
                .critical { color: #990000; font-weight: bold; }
                .message { max-width: 600px; word-wrap: break-word; }
            </style>
        </head>
        <body>
            <h1>Log Export</h1>
            <p>Exported \(entries.count) entries on \(dateFormatter.string(from: Date()))</p>
            <table>
                <thead>
                    <tr>
        """

        if options.includeTimestamps {
            html += "                <th>Timestamp</th>\n"
        }
        if options.includeLevels {
            html += "                <th>Level</th>\n"
        }
        html += "                <th>Message</th>\n"
        if options.includeSourceInfo {
            html += "                <th>Source</th>\n"
        }

        html += """
                    </tr>
                </thead>
                <tbody>
        """

        for entry in entries {
            let levelClass = entry.level.rawValue.lowercased()
            html += "            <tr class=\"\(levelClass)\">\n"

            if options.includeTimestamps {
                html += "                <td>\(escapeHTML(dateFormatter.string(from: entry.timestamp)))</td>\n"
            }

            if options.includeLevels {
                html += "                <td class=\"\(levelClass)\">\(escapeHTML(entry.level.rawValue.uppercased()))</td>\n"
            }

            html += "                <td class=\"message\">\(escapeHTML(entry.message))</td>\n"

            if options.includeSourceInfo {
                var source = ""
                if let file = entry.file {
                    source = file
                    if let line = entry.line {
                        source += ":\(line)"
                    }
                }
                html += "                <td>\(escapeHTML(source))</td>\n"
            }

            html += "            </tr>\n"
        }

        html += """
                </tbody>
            </table>
        </body>
        </html>
        """

        return html.data(using: options.encoding) ?? Data()
    }

    private func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func formatAsMarkdown(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var md = "# Log Export\n\n"
        md += "Exported \(entries.count) entries on \(dateFormatter.string(from: Date()))\n\n"

        md += "| "
        if options.includeTimestamps {
            md += "Timestamp | "
        }
        if options.includeLevels {
            md += "Level | "
        }
        md += "Message |\n"

        md += "| "
        if options.includeTimestamps {
            md += "--- | "
        }
        if options.includeLevels {
            md += "--- | "
        }
        md += "--- |\n"

        for entry in entries {
            md += "| "

            if options.includeTimestamps {
                md += "\(dateFormatter.string(from: entry.timestamp)) | "
            }

            if options.includeLevels {
                md += "**\(entry.level.rawValue.uppercased())** | "
            }

            let message = entry.message
                .replacingOccurrences(of: "|", with: "\\|")
                .replacingOccurrences(of: "\n", with: " ")
            md += "\(message) |\n"
        }

        return md.data(using: options.encoding) ?? Data()
    }

    private func formatAsASL(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var lines: [String] = []

        for entry in entries {
            let level = aslLevel(for: entry.level)
            let timestamp = dateFormatter.string(from: entry.timestamp)
            let line = "\(timestamp) [\(level)] \(entry.message)"
            lines.append(line)
        }

        let output = lines.joined(separator: options.lineSeparator)
        return output.data(using: options.encoding) ?? Data()
    }

    private func aslLevel(for level: LogLevel) -> String {
        switch level {
        case .trace:
            return "Debug"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .critical:
            return "Critical"
        }
    }

    private func formatAsSyslog(_ entries: [LogEntry], options: ExportOptions) -> Data {
        var lines: [String] = []

        let hostname = ProcessInfo.processInfo.hostName
        let appName = Bundle.main.bundleIdentifier ?? "MobileLogger"

        for entry in entries {
            let priority = syslogPriority(for: entry.level)
            let timestamp = syslogTimestamp(entry.timestamp)
            let line = "<\(priority)>1 \(timestamp) \(hostname) \(appName) - - - \(entry.message)"
            lines.append(line)
        }

        let output = lines.joined(separator: options.lineSeparator)
        return output.data(using: options.encoding) ?? Data()
    }

    private func syslogPriority(for level: LogLevel) -> Int {
        let facility = 16 // local0
        let severity: Int
        switch level {
        case .trace, .debug:
            severity = 7 // debug
        case .info:
            severity = 6 // info
        case .notice:
            severity = 5 // notice
        case .warning:
            severity = 4 // warning
        case .error:
            severity = 3 // error
        case .critical:
            severity = 2 // critical
        }
        return facility * 8 + severity
    }

    private func syslogTimestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    // MARK: - Compression

    private func compressData(_ data: Data, compression: CompressionType) throws -> Data {
        #if canImport(Compression)
        guard compression != .none else { return data }

        let algorithm: compression_algorithm
        switch compression {
        case .none:
            return data
        case .gzip:
            return try gzipCompress(data)
        case .zlib:
            algorithm = COMPRESSION_ZLIB
        case .lzma:
            algorithm = COMPRESSION_LZMA
        case .lz4:
            algorithm = COMPRESSION_LZ4
        }

        let destinationBufferSize = data.count
        var destinationBuffer = [UInt8](repeating: 0, count: destinationBufferSize)

        let compressedSize = data.withUnsafeBytes { sourceBuffer in
            compression_encode_buffer(
                &destinationBuffer,
                destinationBufferSize,
                sourceBuffer.bindMemory(to: UInt8.self).baseAddress!,
                data.count,
                nil,
                algorithm
            )
        }

        guard compressedSize > 0 else {
            throw ExportError.compressionFailed(
                NSError(domain: "CompressionError", code: -1)
            )
        }

        return Data(destinationBuffer.prefix(compressedSize))
        #else
        return data
        #endif
    }

    private func gzipCompress(_ data: Data) throws -> Data {
        #if canImport(Compression)
        var result = Data()

        // Gzip header
        result.append(contentsOf: [0x1f, 0x8b]) // Magic number
        result.append(0x08) // Compression method (deflate)
        result.append(0x00) // Flags
        result.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // Modification time
        result.append(0x00) // Extra flags
        result.append(0xff) // OS (unknown)

        // Compress with zlib
        let destinationBufferSize = data.count + 1024
        var destinationBuffer = [UInt8](repeating: 0, count: destinationBufferSize)

        let compressedSize = data.withUnsafeBytes { sourceBuffer in
            compression_encode_buffer(
                &destinationBuffer,
                destinationBufferSize,
                sourceBuffer.bindMemory(to: UInt8.self).baseAddress!,
                data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }

        guard compressedSize > 0 else {
            throw ExportError.compressionFailed(
                NSError(domain: "GzipError", code: -1)
            )
        }

        result.append(contentsOf: destinationBuffer.prefix(compressedSize))

        // CRC32 and original size
        let crc = crc32(data)
        result.append(contentsOf: withUnsafeBytes(of: crc.littleEndian) { Array($0) })
        let size = UInt32(data.count)
        result.append(contentsOf: withUnsafeBytes(of: size.littleEndian) { Array($0) })

        return result
        #else
        return data
        #endif
    }

    private func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        let polynomial: UInt32 = 0xEDB88320

        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 != 0 {
                    crc = (crc >> 1) ^ polynomial
                } else {
                    crc >>= 1
                }
            }
        }

        return ~crc
    }
}

// MARK: - Logger Extension

extension Logger {

    /// Returns recent log entries for export.
    ///
    /// - Parameter limit: Maximum number of entries to return.
    /// - Returns: Array of recent log entries.
    public func recentEntries(limit: Int? = nil) -> [LogEntry] {
        // This would typically access the internal buffer
        // For now, return empty array as placeholder
        return []
    }
}
