import Foundation

/// The text forms of a record shared by the sinks and the export.
enum LogFormat {
    /// The record as one line of JSON with sorted keys, ending in a line feed.
    static func jsonLine(_ record: LogRecord) throws -> Data {
        var data = try encoder.encode(record)
        data.append(UInt8(ascii: "\n"))
        return data
    }

    /// The message followed by the metadata as compact JSON, or by the omitted-metadata note.
    static func messageLine(_ record: LogRecord) -> String {
        if let omitted = record.omittedMetadata { return "\(record.message) \(omitted)" }
        guard !record.metadata.isEmpty else { return record.message }
        return "\(record.message) \(metadataJSON(record.metadata))"
    }

    /// `2026-10-28T09:41:07.250Z [info] Network: Request finished {"status":200}`
    ///
    /// Every line break in the message is followed by four spaces, so a message cannot write a
    /// line that looks like a record of its own.
    static func textLine(_ record: LogRecord) -> String {
        let header = "\(record.date.formatted(LogRecord.dateStyle)) [\(record.level.rawValue)] \(record.category):"
        return indentingLineBreaks("\(header) \(messageLine(record))")
    }

    static func indentingLineBreaks(_ text: String) -> String {
        guard text.contains(where: \.isNewline) else { return text }
        var output = ""
        output.reserveCapacity(text.utf8.count + 16)
        for character in text {
            output.append(character)
            if character.isNewline { output.append("    ") }
        }
        return output
    }

    static func metadataJSON(_ metadata: [String: RedactedValue]) -> String {
        guard let data = try? encoder.encode(metadata), let text = String(data: data, encoding: .utf8) else {
            // Only a `.double(.nan)` made by hand cannot be encoded; never show a value then.
            return "{\"metadata\":\"\(RedactionPolicy.replacement)\"}"
        }
        return text
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}
