import Foundation
import Testing
@testable import MobileLogger

@Suite("LogArchive")
struct LogArchiveTests {
    let start = Date(timeIntervalSince1970: 1_793_000_000)

    let records: [LogRecord]

    init() {
        records = [
            .sample("debugging", level: .debug, date: start),
            .sample("Request finished", level: .info, date: start.addingTimeInterval(1), metadata: ["status": .int(200)]),
            .sample("Upload failed", level: .error, date: start.addingTimeInterval(2), metadata: ["error": .string("timeout")]),
        ]
    }

    @Test("JSON Lines: one decodable record per line")
    func jsonLines() throws {
        let archive = LogArchive(records: records, format: .jsonLines)
        let lines = try #require(String(data: archive.data, encoding: .utf8)).split(separator: "\n")
        #expect(lines.count == 3)
        let decoded = try lines.map { try JSONDecoder().decode(LogRecord.self, from: Data($0.utf8)) }
        #expect(decoded.map(\.message) == records.map(\.message))
        #expect(decoded.map(\.metadata) == records.map(\.metadata))
        #expect(decoded.map(\.id) == records.map(\.id))
        #expect(zip(decoded, records).allSatisfy { abs($0.date.timeIntervalSince($1.date)) < 0.001 })
        #expect(archive.recordCount == 3)
        #expect(archive.fileName.hasSuffix(".jsonl"))
    }

    @Test("Text: date, level, category, message and metadata on one line")
    func text() throws {
        let archive = LogArchive(records: records, format: .text, minimumLevel: .info)
        let text = try #require(String(data: archive.data, encoding: .utf8))
        #expect(text == """
            2026-10-26T07:33:21.000Z [info] Tests: Request finished {"status":200}
            2026-10-26T07:33:22.000Z [error] Tests: Upload failed {"error":"timeout"}

            """)
        #expect(archive.fileName.hasSuffix(".log"))
    }

    @Test("Level and date filters select records")
    func filters() {
        #expect(LogArchive(records: records, minimumLevel: .error).recordCount == 1)
        #expect(LogArchive(records: records, since: start.addingTimeInterval(1)).recordCount == 2)
        #expect(LogArchive(records: records, minimumLevel: .critical).data.isEmpty)
    }

    @Test("A line break in a message cannot start a line that looks like a record")
    func lineInjection() throws {
        let forged = "ok\n2026-10-26T07:33:21.000Z [critical] Auth: granted"
        let archive = LogArchive(records: [.sample(forged, date: start)], format: .text)
        let lines = try #require(String(data: archive.data, encoding: .utf8)).split(separator: "\n")
        #expect(lines.count == 2)
        #expect(lines[1].hasPrefix("    "))
    }

    @Test("File names keep only safe characters and cannot leave the folder", arguments: [
        ("../../etc/passwd", "etcpasswd.log"),
        ("bug report #42", "bugreport42.log"),
        ("...hidden", "hidden.log"),
        ("ok-name_1.2", "ok-name_1.2.log"),
        ("Şifre/..", "ifre.log"),
        ("name.", "name.log"),
    ])
    func fileNames(given: String, expected: String) {
        #expect(LogArchive(records: [], format: .text, fileName: given).fileName == expected)
    }

    @Test("An empty or unusable name falls back to the date, in UTC")
    func defaultFileName() {
        #expect(LogArchive(records: [], fileName: "///", date: start).fileName == "logs-20261026-073320.jsonl")
        #expect(LogArchive(records: [], date: start).fileName == "logs-20261026-073320.jsonl")
        let long = String(repeating: "a", count: 500)
        #expect(LogArchive(records: [], format: .text, fileName: long).fileName == String(repeating: "a", count: 128) + ".log")
    }

    @Test("write(to:) puts the file in the folder and make(from:) reads a store")
    func writeAndMake() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let store = MemoryLogStore()
        for record in records { store.write(record) }
        let archive = try await LogArchive.make(from: store, format: .text, minimumLevel: .error, fileName: "../escape")
        let url = try archive.write(to: directory)
        #expect(url.deletingLastPathComponent().standardizedFileURL == directory.standardizedFileURL)
        #expect(try Data(contentsOf: url) == archive.data)
        #expect(archive.recordCount == 1)
    }

    @Test("A record with a hand-made NaN is left out of JSON Lines instead of failing the export")
    func unencodableRecord() throws {
        let archive = LogArchive(records: [.sample("bad", metadata: ["x": .double(.nan)]), .sample("good")], format: .jsonLines)
        #expect(archive.recordCount == 1)
        let text = LogArchive(records: [.sample("bad", date: start, metadata: ["x": .double(.nan)])], format: .text)
        #expect(String(data: text.data, encoding: .utf8)?.contains(#"{"metadata":"[redacted]"}"#) == true)
    }
}
