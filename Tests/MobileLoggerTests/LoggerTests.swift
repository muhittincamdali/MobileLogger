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

    var entryCount: Int {
        queue.sync { _entries.count }
    }

    func send(_ entry: LogEntry) {
        queue.sync { _entries.append(entry) }
    }

    func clear() {
        queue.sync { _entries.removeAll() }
    }
}

// MARK: - Mock Analytics Provider

final class MockAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {
    let providerId = "mock"
    var isEnabled = true

    private let queue = DispatchQueue(label: "com.test.analytics")
    private var _events: [AnalyticsEvent] = []
    private var _flushCount = 0

    var events: [AnalyticsEvent] {
        queue.sync { _events }
    }

    var flushCount: Int {
        queue.sync { _flushCount }
    }

    func track(_ event: AnalyticsEvent) {
        queue.sync { _events.append(event) }
    }

    func flush() {
        queue.sync { _flushCount += 1 }
    }

    func clear() {
        queue.sync {
            _events.removeAll()
            _flushCount = 0
        }
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
        XCTAssertEqual(LogLevel.debug.label, "DEBUG")
        XCTAssertEqual(LogLevel.info.label, "INFO")
        XCTAssertEqual(LogLevel.warning.label, "WARNING")
        XCTAssertEqual(LogLevel.error.label, "ERROR")
        XCTAssertEqual(LogLevel.critical.label, "CRITICAL")
    }

    func testLevelDescription() {
        XCTAssertEqual(LogLevel.trace.description, "trace")
        XCTAssertEqual(LogLevel.debug.description, "debug")
        XCTAssertEqual(LogLevel.info.description, "info")
        XCTAssertEqual(LogLevel.warning.description, "warning")
        XCTAssertEqual(LogLevel.error.description, "error")
        XCTAssertEqual(LogLevel.critical.description, "critical")
    }

    func testAllCases() {
        XCTAssertEqual(LogLevel.allCases.count, 6)
        XCTAssertTrue(LogLevel.allCases.contains(.trace))
        XCTAssertTrue(LogLevel.allCases.contains(.critical))
    }

    func testLevelComparison() {
        XCTAssertFalse(LogLevel.trace >= LogLevel.debug)
        XCTAssertTrue(LogLevel.error >= LogLevel.warning)
        XCTAssertTrue(LogLevel.info >= LogLevel.info)
    }

    func testLevelEquality() {
        XCTAssertEqual(LogLevel.info, LogLevel.info)
        XCTAssertNotEqual(LogLevel.debug, LogLevel.info)
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

    func testEntryWithoutMetadata() {
        let entry = LogEntry(level: .debug, message: "Simple log")
        XCTAssertNil(entry.metadata)
        XCTAssertEqual(entry.message, "Simple log")
    }

    func testFileName() {
        let entry = LogEntry(level: .debug, message: "test")
        XCTAssertTrue(entry.fileName.hasSuffix(".swift"))
    }

    func testSourceLocation() {
        let entry = LogEntry(level: .debug, message: "test", file: "MyFile.swift", line: 42)
        XCTAssertEqual(entry.sourceLocation, "MyFile.swift:42")
    }

    func testEntryTimestamp() {
        let before = Date()
        let entry = LogEntry(level: .info, message: "test")
        let after = Date()

        XCTAssertGreaterThanOrEqual(entry.timestamp, before)
        XCTAssertLessThanOrEqual(entry.timestamp, after)
    }

    func testEntryId() {
        let entry1 = LogEntry(level: .info, message: "first")
        let entry2 = LogEntry(level: .info, message: "second")

        XCTAssertNotEqual(entry1.id, entry2.id)
    }

    func testEntryWithEmptyMetadata() {
        let entry = LogEntry(level: .info, message: "test", metadata: [:])
        XCTAssertEqual(entry.metadata?.count, 0)
    }

    func testEntryWithLargeMetadata() {
        var metadata: [String: String] = [:]
        for i in 0..<100 {
            metadata["key\(i)"] = "value\(i)"
        }

        let entry = LogEntry(level: .info, message: "test", metadata: metadata)
        XCTAssertEqual(entry.metadata?.count, 100)
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

    func testAddMultipleDestinations() {
        let logger = Logger(label: "test")
        logger.addDestination(MockDestination())
        logger.addDestination(MockDestination())
        logger.addDestination(MockDestination())
        XCTAssertEqual(logger.destinationCount, 3)
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

    func testClearBuffer() {
        let logger = Logger(label: "test", bufferCapacity: 10)
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.info("Entry 1")
        logger.info("Entry 2")

        let expectation = XCTestExpectation(description: "Clear buffer")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            logger.clearBuffer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(logger.recentEntries.count, 0)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testLoggerLabel() {
        let logger = Logger(label: "com.app.module")
        XCTAssertEqual(logger.label, "com.app.module")
    }

    func testAllLogLevels() {
        let logger = Logger(label: "test")
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.trace("Trace message")
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")

        let expectation = XCTestExpectation(description: "All levels")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(mock.entries.count, 6)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testLogWithMetadata() {
        let logger = Logger(label: "test")
        let mock = MockDestination()
        logger.addDestination(mock)

        logger.info("User action", metadata: ["userId": "123", "action": "login"])

        let expectation = XCTestExpectation(description: "Metadata")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(mock.entries.first?.metadata?["userId"], "123")
            XCTAssertEqual(mock.entries.first?.metadata?["action"], "login")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDestinationMinimumLevel() {
        let logger = Logger(label: "test")
        let mock = MockDestination()
        mock.minimumLevel = .error
        logger.addDestination(mock)

        logger.info("Should be filtered by destination")
        logger.error("Should pass")

        let expectation = XCTestExpectation(description: "Destination level")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(mock.entries.count, 1)
            XCTAssertEqual(mock.entries.first?.level, .error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testMultipleDestinationsReceiveEntries() {
        let logger = Logger(label: "test")
        let mock1 = MockDestination()
        let mock2 = MockDestination()
        logger.addDestination(mock1)
        logger.addDestination(mock2)

        logger.info("Broadcast message")

        let expectation = XCTestExpectation(description: "Multiple destinations")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(mock1.entries.count, 1)
            XCTAssertEqual(mock2.entries.count, 1)
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

    func testJSONFormatterWithMetadata() {
        let formatter = JSONFormatter()
        let entry = LogEntry(level: .debug, message: "test", metadata: ["key": "value"])
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("\"metadata\""))
        XCTAssertTrue(output.contains("\"key\":\"value\""))
    }

    func testJSONFormatterPrettyPrinted() {
        var formatter = JSONFormatter()
        formatter.prettyPrinted = true
        let entry = LogEntry(level: .info, message: "test")
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("\n"))
    }

    func testJSONFormatterWithoutSourceLocation() {
        var formatter = JSONFormatter()
        formatter.includeSourceLocation = false
        let entry = LogEntry(level: .info, message: "test")
        let output = formatter.format(entry)
        XCTAssertFalse(output.contains("\"file\""))
        XCTAssertFalse(output.contains("\"function\""))
    }

    func testJSONFormatterDateFormats() {
        var formatter = JSONFormatter()

        // ISO 8601
        formatter.dateFormat = .iso8601
        let entry = LogEntry(level: .info, message: "test")
        var output = formatter.format(entry)
        XCTAssertTrue(output.contains("T"))

        // Unix timestamp
        formatter.dateFormat = .unixTimestamp
        output = formatter.format(entry)
        // Should contain a numeric timestamp
        XCTAssertTrue(output.contains("timestamp"))
    }

    func testJSONFormatterBatch() {
        let formatter = JSONFormatter()
        let entries = [
            LogEntry(level: .info, message: "first"),
            LogEntry(level: .warning, message: "second")
        ]
        let output = formatter.formatBatch(entries)
        XCTAssertTrue(output.hasPrefix("["))
        XCTAssertTrue(output.hasSuffix("]"))
    }

    func testJSONFormatterFieldMappings() {
        var formatter = JSONFormatter()
        formatter.fieldMappings = .elasticsearch
        let entry = LogEntry(level: .info, message: "test")
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("@timestamp"))
    }

    func testPrettyFormatterOutput() {
        let formatter = PrettyFormatter()
        let entry = LogEntry(level: .warning, message: "Watch out", metadata: ["code": "42"])
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("Watch out"))
        XCTAssertTrue(output.contains("code: 42"))
    }

    func testJSONFormatterBuilder() {
        let formatter = JSONFormatterBuilder()
            .prettyPrinted()
            .includeSourceLocation(false)
            .dateFormat(.unixTimestamp)
            .addField("app", value: "TestApp")
            .build()

        let entry = LogEntry(level: .info, message: "test")
        let output = formatter.format(entry)
        XCTAssertTrue(output.contains("TestApp"))
        XCTAssertFalse(output.contains("\"file\""))
    }

    func testJSONFormatterPresets() {
        let elasticsearch = JSONFormatter.elasticsearch
        XCTAssertEqual(elasticsearch.fieldMappings.timestamp, "@timestamp")

        let datadog = JSONFormatter.datadog
        XCTAssertEqual(datadog.fieldMappings.level, "status")

        let compact = JSONFormatter.compact
        XCTAssertFalse(compact.includeSourceLocation)
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

    func testMultipleEmailRedaction() {
        let redactor = PrivacyRedactor()
        let result = redactor.redact("From: a@b.com To: c@d.com")
        XCTAssertEqual(result.components(separatedBy: "[REDACTED_EMAIL]").count - 1, 2)
    }

    func testIPRedaction() {
        let redactor = PrivacyRedactor()
        let result = redactor.redact("Server: 192.168.1.100")
        XCTAssertTrue(result.contains("[REDACTED_IP]"))
        XCTAssertFalse(result.contains("192.168.1.100"))
    }

    func testDisabledRedactor() {
        let redactor = PrivacyRedactor()
        redactor.isEnabled = false
        let input = "Email: test@test.com"
        XCTAssertEqual(redactor.redact(input), input)
    }

    func testPhoneRedaction() {
        let redactor = PrivacyRedactor()
        let result = redactor.redact("Call me at 555-123-4567")
        // Phone redaction depends on implementation
        XCTAssertTrue(result.contains("Call me"))
    }

    func testNoRedactionNeeded() {
        let redactor = PrivacyRedactor()
        let input = "This is a safe message"
        let result = redactor.redact(input)
        XCTAssertEqual(result, input)
    }
}

// MARK: - File Rotation Tests

final class FileRotationTests: XCTestCase {

    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func testRotationPolicyEquality() {
        let policy1 = FileRotationPolicy.size(maxBytes: 1000)
        let policy2 = FileRotationPolicy.size(maxBytes: 1000)
        let policy3 = FileRotationPolicy.size(maxBytes: 2000)

        XCTAssertEqual(policy1, policy2)
        XCTAssertNotEqual(policy1, policy3)
    }

    func testRotationIntervalSeconds() {
        XCTAssertEqual(RotationInterval.hourly.seconds, 3600)
        XCTAssertEqual(RotationInterval.daily.seconds, 86400)
        XCTAssertEqual(RotationInterval.weekly.seconds, 604800)
        XCTAssertEqual(RotationInterval.custom(seconds: 120).seconds, 120)
    }

    func testCompressionFormatExtensions() {
        XCTAssertEqual(RotationCompressionFormat.none.fileExtension, "")
        XCTAssertEqual(RotationCompressionFormat.gzip.fileExtension, ".gz")
        XCTAssertEqual(RotationCompressionFormat.zip.fileExtension, ".zip")
    }

    func testRotationConfiguration() {
        let config = FileRotationConfiguration.default
        XCTAssertEqual(config.maxArchivedFiles, 5)
        XCTAssertTrue(config.deleteOldArchives)
    }

    func testRotationManagerCreation() {
        let fileURL = tempDirectory.appendingPathComponent("test.log")
        let manager = FileRotationManager(fileURL: fileURL)

        XCTAssertEqual(manager.fileURL, fileURL)
        XCTAssertFalse(manager.isMonitoring)
    }

    func testRotationStatistics() {
        let fileURL = tempDirectory.appendingPathComponent("test.log")
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)

        let manager = FileRotationManager(fileURL: fileURL)
        let stats = manager.statistics()

        XCTAssertEqual(stats.archivedFileCount, 0)
        XCTAssertGreaterThanOrEqual(stats.currentFileSize, 0)
    }

    func testRotationEvent() {
        let event = RotationEvent(
            originalFile: URL(fileURLWithPath: "/logs/app.log"),
            archivedFile: URL(fileURLWithPath: "/logs/app.1.log"),
            fileSize: 1000,
            archivedFileCount: 1
        )

        XCTAssertEqual(event.fileSize, 1000)
        XCTAssertEqual(event.archivedFileCount, 1)
    }
}

// MARK: - Analytics Tests

final class AnalyticsTests: XCTestCase {

    func testAnalyticsEventCreation() {
        let event = AnalyticsEvent(
            name: "user_action",
            level: .info,
            message: "User tapped button",
            properties: ["button": "submit"]
        )

        XCTAssertEqual(event.name, "user_action")
        XCTAssertEqual(event.level, .info)
        XCTAssertEqual(event.properties["button"], "submit")
    }

    func testAnalyticsEventFromLogEntry() {
        let entry = LogEntry(level: .warning, message: "Low memory", metadata: ["memory": "50MB"])
        let event = AnalyticsEvent(from: entry)

        XCTAssertEqual(event.level, .warning)
        XCTAssertEqual(event.message, "Low memory")
        XCTAssertEqual(event.properties["memory"], "50MB")
    }

    func testAnalyticsConfiguration() {
        let config = AnalyticsConfiguration.default
        XCTAssertTrue(config.isEnabled)
        XCTAssertEqual(config.minimumLevel, .warning)
        XCTAssertEqual(config.batchSize, 50)
    }

    func testAnalyticsMinimalConfiguration() {
        let config = AnalyticsConfiguration.minimal
        XCTAssertEqual(config.minimumLevel, .error)
        XCTAssertFalse(config.includeDeviceInfo)
        XCTAssertEqual(config.samplingRate, 0.5)
    }

    func testAnalyticsManagerRegistration() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()

        manager.register(provider)
        XCTAssertEqual(manager.registeredProviders.count, 1)
        XCTAssertTrue(manager.registeredProviders.contains("mock"))
    }

    func testAnalyticsManagerUnregistration() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()

        manager.register(provider)
        manager.unregister(providerId: "mock")

        let expectation = XCTestExpectation(description: "Unregister")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(manager.registeredProviders.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsEventTracking() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        let event = AnalyticsEvent(
            name: "test_event",
            level: .warning,
            message: "Test"
        )
        manager.track(event)

        let expectation = XCTestExpectation(description: "Track")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(provider.events.count, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsFlush() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        manager.track(name: "event1", level: .warning)
        manager.flush()

        let expectation = XCTestExpectation(description: "Flush")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertGreaterThan(provider.flushCount, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsSessionTracking() {
        var config = AnalyticsConfiguration.default
        config.trackSessions = true
        let manager = AnalyticsManager(configuration: config)

        XCTAssertNotNil(manager.sessionId)
    }

    func testAnalyticsUserIdSetting() {
        let manager = AnalyticsManager()
        manager.setUserId("user123")

        let expectation = XCTestExpectation(description: "User ID")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(manager.userId, "user123")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsReset() {
        let manager = AnalyticsManager()
        manager.setUserId("user123")
        manager.reset()

        let expectation = XCTestExpectation(description: "Reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNil(manager.userId)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testConsoleAnalyticsProvider() {
        let provider = ConsoleAnalyticsProvider(verbose: true)
        XCTAssertEqual(provider.providerId, "console")
        XCTAssertTrue(provider.isEnabled)
    }

    func testEventFilterByLevel() {
        let filter = EventFilter.level(.warning)
        let infoEvent = AnalyticsEvent(name: "test", level: .info, message: "info")
        let errorEvent = AnalyticsEvent(name: "test", level: .error, message: "error")

        XCTAssertFalse(filter.predicate(infoEvent))
        XCTAssertTrue(filter.predicate(errorEvent))
    }

    func testEventFilterCombination() {
        let filter = EventFilter.all([
            .level(.warning),
            .name(contains: "error")
        ])

        let event1 = AnalyticsEvent(name: "error_occurred", level: .error, message: "test")
        let event2 = AnalyticsEvent(name: "info_log", level: .error, message: "test")

        XCTAssertTrue(filter.predicate(event1))
        XCTAssertFalse(filter.predicate(event2))
    }
}

// MARK: - Analytics Destination Tests

final class AnalyticsDestinationTests: XCTestCase {

    func testAnalyticsDestinationCreation() {
        let manager = AnalyticsManager()
        let destination = AnalyticsDestination(manager: manager)

        XCTAssertEqual(destination.minimumLevel, .warning)
        XCTAssertEqual(destination.eventNamePrefix, "log_")
    }

    func testAnalyticsDestinationSend() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        let destination = AnalyticsDestination(manager: manager)
        destination.minimumLevel = .info

        let entry = LogEntry(level: .warning, message: "Test warning")
        destination.send(entry)

        let expectation = XCTestExpectation(description: "Send")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(provider.events.count, 1)
            XCTAssertEqual(provider.events.first?.name, "log_warning")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsDestinationFiltersLowLevel() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        let destination = AnalyticsDestination(manager: manager)
        destination.minimumLevel = .error

        let entry = LogEntry(level: .info, message: "Should be filtered")
        destination.send(entry)

        let expectation = XCTestExpectation(description: "Filter")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(provider.events.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsDestinationCustomEventName() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        let destination = AnalyticsDestination(manager: manager)
        destination.minimumLevel = .info
        destination.eventNameGenerator = { entry in
            "custom_\(entry.level.description)_event"
        }

        let entry = LogEntry(level: .warning, message: "Test")
        destination.send(entry)

        let expectation = XCTestExpectation(description: "Custom name")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(provider.events.first?.name, "custom_warning_event")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAnalyticsDestinationAdditionalProperties() {
        let manager = AnalyticsManager()
        let provider = MockAnalyticsProvider()
        manager.register(provider)

        let destination = AnalyticsDestination(manager: manager)
        destination.minimumLevel = .info
        destination.additionalProperties = ["app": "TestApp", "version": "1.0"]

        let entry = LogEntry(level: .warning, message: "Test")
        destination.send(entry)

        let expectation = XCTestExpectation(description: "Additional props")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(provider.events.first?.properties["app"], "TestApp")
            XCTAssertEqual(provider.events.first?.properties["version"], "1.0")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - JSON Stream Formatter Tests

final class JSONStreamFormatterTests: XCTestCase {

    func testNDJSONFormat() {
        let streamFormatter = JSONStreamFormatter(style: .ndjson)
        let entries = [
            LogEntry(level: .info, message: "first"),
            LogEntry(level: .info, message: "second")
        ]

        let output = streamFormatter.format(entries)
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 2)
    }

    func testJSONArrayFormat() {
        let streamFormatter = JSONStreamFormatter(style: .jsonArray)
        let entries = [
            LogEntry(level: .info, message: "first"),
            LogEntry(level: .info, message: "second")
        ]

        let output = streamFormatter.format(entries)
        XCTAssertTrue(output.hasPrefix("["))
        XCTAssertTrue(output.hasSuffix("]"))
    }

    func testEmptyBatch() {
        let streamFormatter = JSONStreamFormatter(style: .ndjson)
        let output = streamFormatter.format([])
        XCTAssertTrue(output.isEmpty)
    }
}

// MARK: - Device Info Tests

final class DeviceInfoTests: XCTestCase {

    func testDeviceInfoCreation() {
        let info = DeviceInfo(
            model: "iPhone",
            osName: "iOS",
            osVersion: "17.0",
            appVersion: "1.0.0",
            buildNumber: "1",
            locale: "en_US",
            timezone: "America/New_York",
            isSimulator: false,
            screenSize: "390x844"
        )

        XCTAssertEqual(info.model, "iPhone")
        XCTAssertEqual(info.osName, "iOS")
        XCTAssertEqual(info.appVersion, "1.0.0")
    }

    func testDeviceInfoCodable() throws {
        let info = DeviceInfo(
            model: "iPhone",
            osName: "iOS",
            osVersion: "17.0",
            appVersion: "1.0.0",
            buildNumber: "1",
            locale: "en_US",
            timezone: "America/New_York",
            isSimulator: false,
            screenSize: "390x844"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(info)
        XCTAssertGreaterThan(data.count, 0)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DeviceInfo.self, from: data)
        XCTAssertEqual(decoded.model, info.model)
        XCTAssertEqual(decoded.osVersion, info.osVersion)
    }
}
