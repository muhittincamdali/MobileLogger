import Foundation
import OSLog
import Testing
@testable import MobileLogger

@Suite("OSLogSink")
struct OSLogSinkTests {
    @Test("Unified logging receives the redacted line, and never the secret")
    func writesRedactedText() async throws {
        let subsystem = "io.github.muhittincamdali.MobileLoggerTests.\(UUID().uuidString)"
        let log = MobileLogger(subsystem: subsystem, category: "OSLogSinkTests", sinks: [OSLogSink()])
        let start = Date().addingTimeInterval(-1)
        log.error("Charge failed card=4242424242424242", metadata: ["status": 402])

        let store = try OSLogStore(scope: .currentProcessIdentifier)
        var messages: [String] = []
        for _ in 0..<50 {
            messages = try store.getEntries(at: store.position(date: start), matching: NSPredicate(format: "subsystem == %@", subsystem))
                .compactMap { ($0 as? OSLogEntryLog)?.composedMessage }
            if !messages.isEmpty { break }
            try await Task.sleep(for: .milliseconds(100))
        }
        #expect(messages == [#"Charge failed card=[redacted] {"status":402}"#])
    }

    @Test("The line is the message, then the metadata or the omitted-metadata note")
    func messageLine() {
        #expect(LogFormat.messageLine(.sample("plain")) == "plain")
        #expect(LogFormat.messageLine(.sample("with", metadata: ["b": .int(2), "a": .string("x/y")])) == #"with {"a":"x/y","b":2}"#)
        let omitted = LogRecord(
            date: Date(), level: .info, subsystem: "s", category: "c", message: "big", omittedMetadata: "[metadata omitted: unreadable]",
            source: LogRecord.Source(fileID: "f", function: "g", line: 1)
        )
        #expect(LogFormat.messageLine(omitted) == "big [metadata omitted: unreadable]")
    }
}
