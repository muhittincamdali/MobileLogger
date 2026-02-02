import XCTest
@testable import MobileLogger

// MARK: - Mock Destination

final class MockDestination: LogDestination, @unchecked Sendable {
    var minimumLevel: LogLevel = .trace
    var formatter: LogFormatter = PrettyFormatter()

    private let queue = DispatchQueue(label: "com.test.mock")
    private var _entries: [LogEntry] = []

    var entries: [LogEntry] {
        queue.sync { _entries }
    }

    func send(_ entry: LogEntry) {
        queue.sync { _entries.append(entry) }
    }
}

// MARK: - LogLevel Tests

final class LogLevelTests: XCTestCase {

    func testLevelOrdering() {
        XCTAssertTrue(LogLevel.trace < LogLevel.debug)
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warning)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
        XCTAssertTrue(LogLevel.error < LogLevel.critical)
    }

    func testLevelLabels() {
        XCTAssertEqual(LogLevel.trace.label, "TRACE")
        XCTAssertEqual(LogLevel.critical.label, "CRITICAL")
    }

    func testLevelDescription() {
        XCTAssertEqual(LogLevel.info.description, "info")
        XCTAssertEqual(LogLevel.error.description, "error")
    }

    func testAllCases() {
        XCTAssertEqual(LogLevel.allCases.count, 6)
    }
}

// MARK: - LogEntry Tests

final class LogEntryTests: XCTestCase {

    func testEntryCreation() {
        let entry = LogEntry(level: .info, message: "Hello", metadata: ["key": "value"])
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.message, "Hello")
        XCTAssertEqual(entry.metadata?["key"], "value")
    }

    func testFileName() {
        let entry = LogEntry(level: .debug, message: "test")
        XCTAssertTrue(entry.fileName.hasSuffix(".swift"))
    }

    func testSourceLocation() {
        let entry = LogEntry(level: .debug, message: "test", file: "MyFile.swift", line: 42)
        XCTAssertEqual(entry.sourceLocation, "MyFile.swift:42")
    }
}

// MARK: - Logger Tests

final class LoggerTests: XCTestCase {

    func testAddDestination() {
        let logger = Logger(label: "test")
        let mock = MockDestination()
        logger.addDestination(mock)
        XCTAssertEqual(logger.destinationCount, 1)
    }

    func testRemoveAllDestinations() {
        let logger = Logger(label: "test")
        logger.addDestination(MockDestination())
        logger.addDestination(MockDestination())
        logger.removeAllDestinations()
        XCTAssertEqual(logger.destinationCount, 0)
    }

    func testLogDispatchesToDestination() {
        let logger = Logger(label: "test")
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.info("Test message")

        let expectation = XCTestExpectation(description: "Log dispatched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(mock.entries.count, 1)
            XCTAssertEqual(mock.entries.first?.message, "Test message")
            XCTAssertEqual(mock.entries.first?.level, .info)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testMinimumLevelFiltering() {
        let logger = Logger(label: "test")
        logger.minimumLevel = .warning
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.debug("Should be filtered")
        logger.warning("Should pass")

        let expectation = XCTestExpectation(description: "Filtered")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(mock.entries.count, 1)
            XCTAssertEqual(mock.entries.first?.level, .warning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDisabledLogger() {
        let logger = Logger(label: "test")
        logger.isEnabled = false
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.error("Should not appear")

        let expectation = XCTestExpectation(description: "Disabled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(mock.entries.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testBufferRetainsEntries() {
        let logger = Logger(label: "test", bufferCapacity: 5)
        let mock = MockDestination()
        logger.addDestination(mock)

        for i in 0..<10 {
            logger.info("Entry \(i)")
        }

        let expectation = XCTestExpectation(description: "Buffer")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertLessThanOrEqual(logger.recentEntries.count, 5)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Formatter Tests

final class FormatterTests: XCTestCase {

    func testJSONFormatterOutput() {
        let formatter = JSONFormatter()
        let entry = LogEntry(level: .info, message: "Hello world")
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("\"level\":\"info\""))
        XCTAssertTrue(output.contains("\"message\":\"Hello world\""))
    }

    func testPrettyFormatterOutput() {
        let formatter = PrettyFormatter()
        let entry = LogEntry(level: .warning, message: "Watch out", metadata: ["code": "42"])
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("Watch out"))
        XCTAssertTrue(output.contains("code: 42"))
    }
}

// MARK: - Privacy Tests

final class PrivacyTests: XCTestCase {

    func testEmailRedaction() {
        let redactor = PrivacyRedactor()
        let result = redactor.redact("Contact: john@example.com")
        XCTAssertTrue(result.contains("[REDACTED_EMAIL]"))
        XCTAssertFalse(result.contains("john@example.com"))
    }

    func testIPRedaction() {
        let redactor = PrivacyRedactor()
        let result = redactor.redact("Server: 192.168.1.100")
        XCTAssertTrue(result.contains("[REDACTED_IP]"))
    }

    func testDisabledRedactor() {
        let redactor = PrivacyRedactor()
        redactor.isEnabled = false
        let input = "Email: test@test.com"
        XCTAssertEqual(redactor.redact(input), input)
    }
}
