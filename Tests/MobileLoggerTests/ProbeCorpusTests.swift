import Foundation
import Testing
import iOSSecurityTools
@testable import MobileLogger

/// One line of the spec's shared corpus (REDACTION-SPEC §8 #65), `Resources/ReviewProbes.jsonl`,
/// copied from iOSSecurityTools v2.1.2.
struct ReviewProbe: Decodable, Sendable {
    struct Repeat: Decodable, Sendable {
        let prefix: String
        let unit: String
        let count: Int
        let suffix: String
    }

    let review: String
    let id: Int
    let claim: String
    let kind: String
    let keys: [String]?
    let queryKeys: [String]?
    let type: String?
    let input: String?
    let `repeat`: Repeat?
    let data: String?
    let secret: String

    var text: String {
        if let input { return input }
        guard let piece = self.repeat else { return "" }
        return piece.prefix + String(repeating: piece.unit, count: piece.count) + piece.suffix
    }

    static let all: [ReviewProbe] = {
        guard let url = Bundle.module.url(forResource: "ReviewProbes", withExtension: "jsonl"),
              let data = try? Data(contentsOf: url)
        else { return [] }
        let decoder = JSONDecoder()
        return data.split(separator: UInt8(ascii: "\n")).compactMap { try? decoder.decode(ReviewProbe.self, from: Data($0)) }
    }()
}

/// The logger must write exactly what the spec's reference redactor writes, for every probe of
/// the shared corpus, on the path that matches the probe's kind: a message for `text`, a
/// `LogValue.body` for `body`, a `LogValue.url` for `url`. Equal output means the logger never
/// shows more than the redactor; the export check then shows that writing a record to a file
/// adds no reading of its own.
@Suite("Redaction spec §8 #65: the shared probe corpus through MobileLogger")
struct ProbeCorpusTests {
    @Test("The corpus has the lines and claims the spec counts")
    func corpusShape() {
        let claims = Dictionary(grouping: ReviewProbe.all, by: \.claim).mapValues(\.count)
        #expect(ReviewProbe.all.count == 7_866)
        #expect(claims == ["C": 7_234, "X": 476, "K": 78, "D": 78])
    }

    @Test("Every probe is written exactly as the reference redactor writes it, and its export adds nothing")
    func everyProbe() {
        var mismatches: [String] = []
        var leaks: [String] = []
        for probe in ReviewProbe.all {
            let policy = RedactionPolicy(
                allowedTextKeys: probe.kind == "url" ? [] : probe.keys ?? [],
                allowedQueryParameters: probe.kind == "url" ? probe.keys ?? [] : probe.queryKeys ?? []
            )
            let redactor = SensitiveDataRedactor(
                allowedTextKeys: policy.allowedTextKeys, allowedQueryParameters: policy.allowedQueryParameters
            )
            let logger = MobileLogger(category: "Probes", policy: policy, sinks: [])
            let source = LogRecord.Source(fileID: "MobileLoggerTests/ProbeCorpusTests.swift", function: "everyProbe", line: 1)
            let expected: String
            let written: String?
            let record: LogRecord
            switch probe.kind {
            case "url":
                guard let url = URL(string: probe.text) else { continue }
                expected = redactor.redact(url: url)
                record = logger.makeRecord(level: .info, message: "probe", metadata: ["url": .url(url)], source: source)
                written = record.metadata["url"]?.stringValue
            case "body":
                let body = probe.data.flatMap { Data(base64Encoded: $0) } ?? Data(probe.text.utf8)
                expected = redactor.redact(body: body, contentType: probe.type)
                record = logger.makeRecord(level: .info, message: "probe", metadata: ["body": .body(body, contentType: probe.type)], source: source)
                written = record.metadata["body"]?.stringValue
            default:
                let text = probe.text
                expected = text.utf8.count > policy.maximumMessageBytes ? replacement : redactor.redact(text)
                record = logger.makeRecord(level: .info, message: text, metadata: [:], source: source)
                written = record.message
            }
            if written != expected { mismatches.append("\(probe.review)#\(probe.id)") }
            if probe.claim == "C" || probe.claim == "X", !expected.contains(probe.secret) {
                let export = String(decoding: LogArchive(records: [record], format: .text).data, as: UTF8.self)
                if export.contains(probe.secret) { leaks.append("\(probe.review)#\(probe.id)") }
            }
        }
        #expect(mismatches.isEmpty, "\(mismatches.count) probes differ: \(mismatches.prefix(20))")
        #expect(leaks.isEmpty, "\(leaks.count) probes leak in the export: \(leaks.prefix(20))")
    }
}
