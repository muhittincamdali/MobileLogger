import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// The file formats of an export.
public enum LogExportFormat: String, Sendable, Hashable, CaseIterable {
    /// One JSON object per line ([JSON Lines](https://jsonlines.org)), for `jq` and log tools.
    case jsonLines
    /// One readable line per record: date, level, category, message and metadata.
    case text

    /// `jsonl` or `log`.
    public var fileExtension: String {
        switch self {
        case .jsonLines: "jsonl"
        case .text: "log"
        }
    }
}

/// Redacted log records as a file to share or save.
///
/// The records were redacted when they were logged, so an archive holds nothing a sink did not
/// already see. Share it with `ShareLink`, or write it to a folder:
///
/// ```swift
/// let archive = try await LogArchive.make(from: store, format: .text, minimumLevel: .info)
/// ShareLink(item: archive, preview: SharePreview(archive.fileName))
/// ```
public struct LogArchive: Sendable, Hashable, Transferable {
    /// The file's content, UTF-8.
    public let data: Data
    public let format: LogExportFormat
    /// A file name of letters, digits, `.`, `_` and `-`, ending in the format's extension.
    public let fileName: String
    /// How many records the file holds.
    public let recordCount: Int

    /// The longest file name kept, in characters.
    public static let maximumFileNameLength = 128

    /// Makes an archive of the records at or above `minimumLevel` logged at or after `since`.
    ///
    /// - Parameters:
    ///   - records: The records, in the order to write them.
    ///   - format: The file format.
    ///   - minimumLevel: The lowest level included.
    ///   - since: The earliest date included; all records when nil.
    ///   - fileName: The file name without extension. Characters other than ASCII letters,
    ///     digits, `.`, `_` and `-` are dropped, so a name cannot point into another folder;
    ///   `logs-<date>` when nothing is left.
    ///   - date: The date in the default file name.
    public init(
        records: [LogRecord], format: LogExportFormat = .jsonLines, minimumLevel: LogLevel = .trace, since: Date? = nil,
        fileName: String? = nil, date: Date = Date()
    ) {
        let selected = records.filter { record in record.level >= minimumLevel && since.map { record.date >= $0 } ?? true }
        var data = Data()
        var count = 0
        for record in selected {
            switch format {
            case .jsonLines:
                guard let line = try? LogFormat.jsonLine(record) else { continue }
                data.append(line)
            case .text:
                data.append(contentsOf: Array(LogFormat.textLine(record).utf8))
                data.append(UInt8(ascii: "\n"))
            }
            count += 1
        }
        self.data = data
        self.format = format
        self.recordCount = count
        let stem = fileName.map(Self.safeFileStem).flatMap { $0.isEmpty ? nil : $0 } ?? Self.defaultFileStem(date)
        self.fileName = "\(stem).\(format.fileExtension)"
    }

    /// Reads the records of a store and makes an archive of them.
    public static func make(
        from source: some LogRecordSource, format: LogExportFormat = .jsonLines, minimumLevel: LogLevel = .trace, since: Date? = nil,
        fileName: String? = nil
    ) async throws -> LogArchive {
        LogArchive(records: try await source.records(), format: format, minimumLevel: minimumLevel, since: since, fileName: fileName)
    }

    /// Writes the archive into `directory` under ``fileName``, replacing a file of that name,
    /// and returns the file's URL.
    @discardableResult
    public func write(to directory: URL) throws -> URL {
        let url = directory.appending(path: fileName, directoryHint: .notDirectory)
        try data.write(to: url, options: .atomic)
        return url
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8PlainText) { archive in archive.data }
            .suggestedFileName { archive in archive.fileName }
    }

    /// The name without the characters a file name should not have, and without dots at its
    /// start or end.
    static func safeFileStem(_ name: String) -> String {
        let allowed = name.unicodeScalars.filter { scalar in
            scalar.isASCII && (scalar.properties.isAlphabetic || ("0"..."9").contains(scalar) || "._-".unicodeScalars.contains(scalar))
        }
        let stem = String(String.UnicodeScalarView(allowed)).prefix(maximumFileNameLength)
        return String(stem.drop { $0 == "." }.reversed().drop { $0 == "." }.reversed())
    }

    /// `logs-20261028-094107`, in UTC.
    static func defaultFileStem(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        func two(_ value: Int?) -> String { String(format: "%02d", value ?? 0) }
        return "logs-\(parts.year ?? 1970)\(two(parts.month))\(two(parts.day))-\(two(parts.hour))\(two(parts.minute))\(two(parts.second))"
    }
}
