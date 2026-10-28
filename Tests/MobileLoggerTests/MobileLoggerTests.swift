import Foundation
import Synchronization
import Testing
@testable import MobileLogger

@Suite("MobileLogger")
struct MobileLoggerTests {
    @Test("Every sink receives the same redacted record")
    func sinksReceiveRedactedRecords() throws {
        let first = CollectingSink()
        let second = CollectingSink()
        let log = MobileLogger(subsystem: "io.example", category: "Auth", sinks: [first, second])
        log.warning("Sign-in failed password=hunter2", metadata: ["email": "alice@example.com", "attempt": 3])
        let record = try #require(first.records.first)
        #expect(second.records == [record])
        #expect(record.message == "Sign-in failed password=[redacted]")
        #expect(record.metadata == ["email": .string("a•••@example.com"), "attempt": .int(3)])
        #expect(record.level == .warning)
        #expect(record.subsystem == "io.example")
        #expect(record.category == "Auth")
        #expect(record.source.fileID == "MobileLoggerTests/MobileLoggerTests.swift")
    }

    @Test("Messages below the minimum level are not evaluated")
    func levelFiltering() {
        let sink = CollectingSink()
        var log = MobileLogger(category: "Tests", minimumLevel: .warning, sinks: [sink])
        let evaluated = Mutex(0)
        func message(_ text: String) -> String {
            evaluated.withLock { $0 += 1 }
            return text
        }
        log.debug(message("hidden"))
        log.info(message("hidden"))
        log.error(message("shown"))
        #expect(sink.records.map(\.message) == ["shown"])
        #expect(evaluated.withLock { $0 } == 1)
        log.minimumLevel = .trace
        log.trace("now shown")
        #expect(sink.records.count == 2)
    }

    @Test("Each level method writes its level", arguments: LogLevel.allCases)
    func levelMethods(level: LogLevel) {
        let sink = CollectingSink()
        let log = MobileLogger(category: "Tests", minimumLevel: .trace, sinks: [sink])
        switch level {
        case .trace: log.trace("m")
        case .debug: log.debug("m")
        case .info: log.info("m")
        case .notice: log.notice("m")
        case .warning: log.warning("m")
        case .error: log.error("m")
        case .critical: log.critical("m")
        }
        #expect(sink.records.map(\.level) == [level])
    }

    @Test("Levels are ordered and map to unified logging types")
    func levelOrder() {
        #expect(LogLevel.allCases == LogLevel.allCases.sorted())
        #expect(LogLevel.trace.osLogType == .debug)
        #expect(LogLevel.notice.osLogType == .default)
        #expect(LogLevel.warning.osLogType == .error)
        #expect(LogLevel.critical.osLogType == .fault)
    }

    @Test("A logger without sinks is disabled")
    func noSinks() {
        #expect(!MobileLogger(sinks: []).isEnabled(.critical))
        #expect(MobileLogger(sinks: [CollectingSink()]).isEnabled(.debug))
        #expect(!MobileLogger(sinks: [CollectingSink()]).isEnabled(.trace))
    }

    @Test("withCategory keeps everything but the category")
    func withCategory() {
        let sink = CollectingSink()
        var log = MobileLogger(subsystem: "io.example", category: "A", minimumLevel: .error, metadata: ["build": "7"], sinks: [sink])
        log = log.withCategory("B")
        log.info("dropped")
        log.error("kept")
        #expect(sink.records.map(\.category) == ["B"])
        #expect(sink.records.first?.metadata["build"] == .string("7"))
        #expect(sink.records.first?.subsystem == "io.example")
    }

    @Test("A message of exactly the limit is read; one byte more is hidden whole")
    func messageLimitBoundary() {
        let policy = RedactionPolicy(maximumMessageBytes: 16)
        #expect(redactedMessage("status=200 ok ok", policy: policy) == "status=200 ok ok")
        #expect(redactedMessage("status=200 ok ok!", policy: policy) == replacement)
        #expect(redactedMessage("é", policy: RedactionPolicy(maximumMessageBytes: 1)) == replacement)
        #expect(redactedMessage("", policy: RedactionPolicy(maximumMessageBytes: -5)) == "")
    }

    @Test("Many threads can log at once")
    func concurrentLogging() async {
        let sink = CollectingSink()
        let log = MobileLogger(category: "Tests", sinks: [sink])
        await withTaskGroup(of: Void.self) { group in
            for task in 0..<8 {
                group.addTask {
                    for index in 0..<250 { log.info("event", metadata: ["task": .int(task), "index": .int(index)]) }
                }
            }
        }
        #expect(sink.records.count == 2_000)
    }
}
