import Foundation
import Logging
import MobileLogger
import Testing
@testable import MobileLoggerSwiftLog

@Suite("RedactingLogHandler")
struct RedactingLogHandlerTests {
    func makeLogger(_ store: MemoryLogStore, level: Logging.Logger.Level = .trace, provider: Logging.Logger.MetadataProvider? = nil) -> Logging.Logger {
        let base = MobileLogger(subsystem: "io.example", minimumLevel: .trace, sinks: [store])
        return Logging.Logger(label: "com.example.network") { label in
            RedactingLogHandler(label: label, logger: base, logLevel: level, metadataProvider: provider)
        }
    }

    @Test("swift-log messages and metadata of every kind are redacted; the label is the category")
    func redactsMessagesAndMetadata() throws {
        let store = MemoryLogStore()
        var logger = makeLogger(store)
        logger[metadataKey: "request_id"] = "r-17"
        logger.info("Fetched token=abc123", metadata: [
            "status": .stringConvertible(200),
            "headers": .dictionary(["Authorization": "Bearer abcdefgh12345678", "Accept": "application/json"]),
            "numbers": .array(["4242 4242 4242 4242"]),
        ])
        let record = try #require(store.records().first)
        #expect(record.message == "Fetched token=[redacted]")
        #expect(record.category == "com.example.network")
        #expect(record.subsystem == "io.example")
        #expect(record.metadata["request_id"] == .string("r-17"))
        #expect(record.metadata["status"] == .string("200"))
        #expect(record.metadata["headers"] == .object(["Authorization": .string("[redacted]"), "Accept": .string("application/json")]))
        #expect(record.metadata["numbers"] == .array([.string("•••• 4242")]))
    }

    @Test("Levels map one to one, and swift-log's level filters first", arguments: [
        (Logging.Logger.Level.trace, LogLevel.trace), (.debug, .debug), (.info, .info), (.notice, .notice),
        (.warning, .warning), (.error, .error), (.critical, .critical),
    ])
    func levels(swiftLog: Logging.Logger.Level, expected: LogLevel) {
        #expect(LogLevel(swiftLog) == expected)
        let store = MemoryLogStore()
        let logger = makeLogger(store, level: .warning)
        logger.log(level: swiftLog, "m")
        #expect(store.records().map(\.level) == (swiftLog >= .warning ? [expected] : []))
    }

    @Test("A metadata provider is read, and metadata at the call site wins")
    func metadataProvider() throws {
        let store = MemoryLogStore()
        let provider = Logging.Logger.MetadataProvider { ["trace_id": "t-1", "screen": "home"] }
        let logger = makeLogger(store, provider: provider)
        logger.notice("Shown", metadata: ["screen": "cart"])
        let record = try #require(store.records().first)
        #expect(record.metadata == ["trace_id": .string("t-1"), "screen": .string("cart")])
    }

    @Test("Deep swift-log metadata is cut off before it is walked")
    func deepMetadata() throws {
        var value: Logging.Logger.Metadata.Value = "leaf"
        for _ in 0..<200 { value = .array([value]) }
        let converted = RedactingLogHandler.value(value)
        var depth = 0
        var current = converted
        while case .array(let elements) = current, let first = elements.first {
            depth += 1
            current = first
        }
        #expect(depth == RedactingLogHandler.maximumDepth)
        #expect(current == .string(RedactionPolicy.replacement))
        let store = MemoryLogStore()
        makeLogger(store).info("deep", metadata: ["deep": value])
        #expect(store.records().first?.omittedMetadata == nil)
    }

    @Test("Handler metadata is read and written through the subscript")
    func subscriptMetadata() {
        var handler = RedactingLogHandler(label: "x", logger: MobileLogger(sinks: []))
        handler[metadataKey: "a"] = "1"
        #expect(handler[metadataKey: "a"] == "1")
        #expect(handler.metadata == ["a": "1"])
    }
}
