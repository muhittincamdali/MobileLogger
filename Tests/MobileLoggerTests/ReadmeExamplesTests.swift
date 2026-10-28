import Foundation
import OSLog
import Testing
@testable import MobileLogger

/// The README samples in `ReadmeExamples.swift` (a symlink to the example app's
/// `ReadmeSamples.swift`) write what the README says they write.
@Suite("README samples", .serialized)
struct ReadmeExamplesTests {
    @Test("Quick start: unified logging shows the redacted line of the comment")
    func quickStartLine() async throws {
        let start = Date().addingTimeInterval(-1)
        quickStart()
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let predicate = NSPredicate(format: "subsystem == %@ AND category == %@", MobileLogger.defaultSubsystem, "Checkout")
        var messages: [String] = []
        for _ in 0..<50 {
            messages = try store.getEntries(at: store.position(date: start), matching: predicate).compactMap { ($0 as? OSLogEntryLog)?.composedMessage }
            if !messages.isEmpty { break }
            try await Task.sleep(for: .milliseconds(100))
        }
        #expect(messages.last == #"Payment sent {"email":"a•••@example.com","note":"paid with •••• 4242","password":"[redacted]","status":200}"#)
    }

    @Test("Messages and metadata")
    func messages() {
        let sink = CollectingSink()
        messagesAndMetadata(log: MobileLogger(category: "Readme", sinks: [sink]))
        #expect(sink.records.map(\.message) == ["Signed in user=[redacted]", "GET /orders status=200 duration_ms=41", "Signed in"])
        #expect(sink.records.last?.metadata == ["attempt": .int(2), "user": .string("alice")])
    }

    @Test("URLs and bodies")
    func urls() throws {
        let sink = CollectingSink()
        urlsAndBodies(log: MobileLogger(category: "Readme", sinks: [sink]))
        let record = try #require(sink.records.first)
        #expect(LogFormat.messageLine(record) == #"Request finished {"response":"{\"id\":7,\"access_token\":\"[redacted]\",\"items\":3}","status":200,"url":"https://api.example.com/users/:id/orders?page=[redacted]"}"#)
    }

    @Test("Stores and export: the archive holds the warning and nothing unredacted")
    func storesAndExportArchive() async throws {
        await FileLogStore().removeAll()
        let archive = try await storesAndExport()
        await FileLogStore().removeAll()
        let text = try #require(String(data: archive.data, encoding: .utf8))
        #expect(archive.recordCount == 1)
        #expect(text.contains("[error] Sync: Upload failed {"))
        #expect(text.contains(#""attempt":3"#))
        #expect(archive.fileName.hasSuffix(".log"))

        // Nothing unredacted: the line is the one the redactor makes from the sample's input,
        // and the error's raw description appears only where the redactor kept it whole.
        let error = URLError(.timedOut)
        let redacted = record("Upload failed", metadata: ["error": .error(error), "attempt": 3])
        #expect(text.contains("Sync: \(LogFormat.messageLine(redacted))\n"))
        let raw = String(describing: error)
        guard case .object(let members) = redacted.metadata["error"] else {
            Issue.record("Expected the error as an object")
            return
        }
        #expect(text.contains(raw) == (members["description"] == .string(raw)))
    }

    @Test("Policy: allowed keys read on in messages")
    func policyKeys() throws {
        let sink = CollectingSink()
        let base = policy()
        let log = MobileLogger(category: base.category, policy: base.policy, sinks: [sink])
        log.info("Opened screen=home attempt=2 token=abc")
        #expect(sink.records.first?.message == "Opened screen=home attempt=2 token=[redacted]")
        log.info("Loaded", metadata: ["url": .url(URL(string: "https://example.com/items?page=3&q=shoes")!)])
        #expect(sink.records.last?.metadata["url"] == .string("https://example.com/items?page=3&q=[redacted]"))
    }
}
