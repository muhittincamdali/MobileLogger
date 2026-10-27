import Foundation

/// One log message after redaction: what every ``LogSink`` receives.
///
/// The ``message`` and ``metadata`` hold only what the redactor let through, so a record can be
/// kept on disk, shown in the app and exported without another pass. The subsystem, category
/// and source location are written by the developer in code, not taken from data, and are kept
/// as they are.
public struct LogRecord: Sendable, Hashable, Identifiable {
    /// Where in the code a message was logged.
    public struct Source: Sendable, Hashable, Codable {
        /// The file, as `#fileID` writes it (`Module/File.swift`), so no local path is recorded.
        public let fileID: String
        /// The function, as `#function` writes it.
        public let function: String
        /// The line number.
        public let line: Int

        public init(fileID: String, function: String, line: Int) {
            self.fileID = fileID
            self.function = function
            self.line = line
        }
    }

    public let id: UUID
    /// When the message was logged.
    public let date: Date
    public let level: LogLevel
    /// The subsystem of the logger, usually the bundle identifier.
    public let subsystem: String
    /// The category of the logger, such as `Network` or `Checkout`.
    public let category: String
    /// The message, redacted as free text.
    public let message: String
    /// The metadata, redacted as one JSON object.
    public let metadata: [String: RedactedValue]
    /// Set instead of ``metadata`` when the metadata could not be read within the limits of the
    /// redaction spec, such as JSON nested more than 64 levels or larger than
    /// ``RedactionPolicy/maximumBodySize``: a note such as
    /// `[body omitted: 300000 bytes, application/json]`. No value of it is kept.
    public let omittedMetadata: String?
    public let source: Source

    public init(
        id: UUID = UUID(), date: Date, level: LogLevel, subsystem: String, category: String, message: String,
        metadata: [String: RedactedValue] = [:], omittedMetadata: String? = nil, source: Source
    ) {
        self.id = id
        self.date = date
        self.level = level
        self.subsystem = subsystem
        self.category = category
        self.message = message
        self.metadata = metadata
        self.omittedMetadata = omittedMetadata
        self.source = source
    }

    /// A rough count of the bytes the record takes, for the memory budget of ``MemoryLogStore``.
    var estimatedSize: Int {
        let fixed = 160 + subsystem.utf8.count + category.utf8.count + source.fileID.utf8.count + source.function.utf8.count
        return fixed + message.utf8.count + (omittedMetadata?.utf8.count ?? 0) + RedactedValue.object(metadata).estimatedSize
    }
}

extension LogRecord: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, date, level, subsystem, category, message, metadata, omittedMetadata, source
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let text = try container.decode(String.self, forKey: .date)
        guard let date = try? Date(text, strategy: Self.dateStyle) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Not an ISO 8601 date: \(text)")
        }
        self.date = date
        level = try container.decode(LogLevel.self, forKey: .level)
        subsystem = try container.decode(String.self, forKey: .subsystem)
        category = try container.decode(String.self, forKey: .category)
        message = try container.decode(String.self, forKey: .message)
        metadata = try container.decodeIfPresent([String: RedactedValue].self, forKey: .metadata) ?? [:]
        omittedMetadata = try container.decodeIfPresent(String.self, forKey: .omittedMetadata)
        source = try container.decode(Source.self, forKey: .source)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date.formatted(Self.dateStyle), forKey: .date)
        try container.encode(level, forKey: .level)
        try container.encode(subsystem, forKey: .subsystem)
        try container.encode(category, forKey: .category)
        try container.encode(message, forKey: .message)
        if !metadata.isEmpty { try container.encode(metadata, forKey: .metadata) }
        try container.encodeIfPresent(omittedMetadata, forKey: .omittedMetadata)
        try container.encode(source, forKey: .source)
    }

    /// ISO 8601 in UTC with milliseconds: `2026-10-28T09:41:07.250Z`.
    static let dateStyle = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
}
