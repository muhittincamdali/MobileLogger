import Foundation
import Testing
@testable import MobileLogger

@Suite("Metadata redaction")
struct MetadataRedactionTests {
    @Test("Plain keys keep their values and their JSON types")
    func plainValues() {
        let values = record(metadata: [
            "screen": "home", "count": 3, "ratio": 0.25, "enabled": true, "missing": nil, "tags": ["a", "b"],
        ]).metadata
        #expect(values == [
            "screen": .string("home"), "count": .int(3), "ratio": .double(0.25), "enabled": .bool(true), "missing": .null,
            "tags": .array([.string("a"), .string("b")]),
        ])
    }

    @Test("A URL and a body are read by their own parsers and put back where their key keeps them")
    func urlAndBodyKept() {
        let values = record(metadata: [
            "url": .url(URL(string: "https://api.example.com/users/12345678?page=2")!),
            "response": .body(Data(#"{"id":7,"token":"abc"}"#.utf8), contentType: "application/json"),
            "nested": ["link": .url(URL(string: "https://example.com/a")!)],
            "list": [.url(URL(string: "https://example.com/b")!)],
        ]).metadata
        #expect(values["url"] == .string("https://api.example.com/users/:id?page=[redacted]"))
        #expect(values["response"] == .string(#"{"id":7,"token":"[redacted]"}"#))
        #expect(values["nested"] == .object(["link": .string("https://example.com/a")]))
        #expect(values["list"] == .array([.string("https://example.com/b")]))
    }

    @Test("A URL or body under a secret key, or beside a held secret name, stays hidden")
    func urlAndBodyHidden() {
        let url = LogValue.url(URL(string: "https://example.com/a")!)
        #expect(redactedValue(url, key: "token") == .string(replacement))
        #expect(redactedValue(.body(Data("hello".utf8), contentType: "text/plain"), key: "session_cookie") == .string(replacement))
        let beside = record(metadata: ["field": "password", "value": url]).metadata
        #expect(beside["value"] == .string(replacement))
        #expect(redactedValue(url, key: "ünïcode") == .string(replacement))
    }

    @Test("A string that equals the internal marker is never mistaken for a URL")
    func markerAsString() {
        #expect(redactedValue(.string(RecordRedactor.marker), key: "note") == .string(replacement))
    }

    @Test("Non-finite doubles are written as strings instead of trapping in JSONSerialization", arguments: [
        (Double.nan, "nan"), (Double.infinity, "inf"), (-Double.infinity, "-inf"), (Double.signalingNaN, "nan"),
    ])
    func nonFiniteDoubles(number: Double, expected: String) {
        #expect(redactedValue(.double(number), key: "ratio") == .string(expected))
    }

    @Test("Extreme integers convert without trapping", arguments: [Int.min, Int.max, -1, 0])
    func extremeIntegers(number: Int) throws {
        let value = try #require(redactedValue(.int(number), key: "n"))
        switch value {
        case .int(let kept): #expect(kept == number)
        case .string(let text): #expect(!text.isEmpty && number.magnitude >= RecordRedactor.smallestDigitString)
        default: Issue.record("Unexpected \(value)")
        }
    }

    @Test("The logger's metadata is merged, and a key at the call site wins")
    func baseMetadata() {
        let sink = CollectingSink()
        let log = MobileLogger(category: "Tests", metadata: ["build": "1.0", "screen": "home"], sinks: [sink])
        log.info("Shown", metadata: ["screen": "cart"])
        #expect(sink.records.first?.metadata == ["build": .string("1.0"), "screen": .string("cart")])
    }

    @Test("Metadata nested 64 levels is read; 65 levels is omitted whole")
    func depthLimit() {
        func nested(_ levels: Int) -> LogValue {
            var value: LogValue = "leaf"
            for _ in 0..<levels { value = .array([value]) }
            return value
        }
        let kept = record(metadata: ["deep": nested(63)])
        #expect(kept.omittedMetadata == nil)
        #expect(kept.metadata["deep"] != nil)
        let omitted = record(metadata: ["deep": nested(64), "password": "hunter2"])
        #expect(omitted.metadata.isEmpty)
        #expect(omitted.omittedMetadata == RecordRedactor.MetadataFailure.tooDeep.note)
    }

    @Test("Very deep metadata stops at the limit instead of overflowing the stack")
    func veryDeepMetadata() {
        var value: LogValue = "leaf"
        for _ in 0..<1_000 { value = .dictionary(["k": value]) }
        #expect(record(metadata: ["deep": value]).omittedMetadata == RecordRedactor.MetadataFailure.tooDeep.note)
    }

    @Test("Metadata larger than the body limit is omitted before it is copied into JSON")
    func sizeLimit() {
        let policy = RedactionPolicy(maximumBodySize: 1_024)
        let large = record(metadata: ["blob": .string(String(repeating: "a", count: 2_000)), "id": 1], policy: policy)
        #expect(large.metadata.isEmpty)
        #expect(large.omittedMetadata == RecordRedactor.MetadataFailure.tooLarge.note)
        let small = record(metadata: ["blob": .string(String(repeating: "a", count: 900))], policy: policy)
        #expect(small.omittedMetadata == nil)
    }

    @Test("A URL longer than the body limit is hidden whole")
    func longURL() {
        let policy = RedactionPolicy(maximumBodySize: 1_024)
        let url = URL(string: "https://example.com/" + String(repeating: "a", count: 2_000))!
        #expect(redactedValue(.url(url), key: "url", policy: policy) == .string(replacement))
    }

    @Test("An error becomes its type and redacted description")
    func errors() {
        struct UploadError: Error, CustomStringConvertible {
            var description: String { "upload failed for token=abc123" }
        }
        let value = redactedValue(.error(UploadError()), key: "error")
        guard case .object(let members) = value else {
            Issue.record("Expected an object, got \(String(describing: value))")
            return
        }
        #expect(members["description"] == .string("upload failed for token=[redacted]"))
        #expect(members["kind"]?.stringValue?.hasSuffix("UploadError") == true)
    }
}
