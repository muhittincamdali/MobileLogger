import Foundation
import Testing
@testable import MobileLogger

@Suite("FileLogStore")
struct FileLogStoreTests {
    @Test("Records come back in order after a round trip through the disk")
    func roundTrip() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory)
        let log = MobileLogger(category: "Tests", sinks: [store])
        log.info("first", metadata: ["status": 200, "url": .url(URL(string: "https://example.com/users/12345678")!)])
        log.error("second password=hunter2")
        let records = await store.records()
        #expect(records.map(\.message) == ["first", "second password=[redacted]"])
        #expect(records.first?.metadata == ["status": .int(200), "url": .string("https://example.com/users/:id")])
        let text = try String(contentsOf: directory.appending(path: "log.jsonl"), encoding: .utf8)
        #expect(!text.contains("hunter2"))
        #expect(!text.contains("12345678"))
    }

    @Test("Rotation keeps at most the file count, each within the file size, and drops the oldest")
    func rotation() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory, maximumFileSize: 0, maximumFileCount: 3)
        #expect(store.maximumFileSize == FileLogStore.fileSizeRange.lowerBound)
        let padding = String(repeating: "p", count: 1_000)
        for index in 0..<400 { store.write(.sample("m\(index) \(padding)")) }
        let records = await store.records()
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false)).sorted()
        #expect(files == ["log.1.jsonl", "log.2.jsonl", "log.jsonl"])
        for file in files {
            let size = try #require(try FileManager.default.attributesOfItem(atPath: directory.appending(path: file).path(percentEncoded: false))[.size] as? Int)
            #expect(size <= store.maximumFileSize)
        }
        #expect(records.last?.message.hasPrefix("m399 ") == true)
        #expect(records.count < 400)
        let numbers = records.compactMap { Int($0.message.dropFirst().prefix { $0 != " " }) }
        #expect(numbers == numbers.sorted())
        #expect(numbers == Array((400 - numbers.count)..<400))
    }

    @Test("A line that does not decode is skipped; the rest is read")
    func corruptedLine() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory)
        store.write(.sample("before"))
        await store.flush()
        let handle = try FileHandle(forWritingTo: directory.appending(path: "log.jsonl"))
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{not json\n\u{FF}\u{FE}garbage\n".utf8))
        try handle.close()
        let reopened = FileLogStore(directory: directory)
        reopened.write(.sample("after"))
        #expect(await reopened.records().map(\.message) == ["before", "after"])
    }

    @Test("A planted line nested 100,000 levels deep is skipped without exhausting the stack")
    func deeplyNestedLine() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var planted = Data(#"{"metadata":{"a":"#.utf8)
        planted.append(Data(repeating: UInt8(ascii: "["), count: 100_000))
        planted.append(Data(repeating: UInt8(ascii: "]"), count: 100_000))
        planted.append(Data("}}\n".utf8))
        try planted.write(to: directory.appending(path: "log.1.jsonl"))
        let store = FileLogStore(directory: directory)
        store.write(.sample("own"))
        #expect(await store.records().map(\.message) == ["own"])
    }

    @Test("A file larger than twice the file size is not read")
    func oversizedFile() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let line = try LogFormat.jsonLine(.sample("planted"))
        var data = Data()
        while data.count <= FileLogStore.fileSizeRange.lowerBound * 2 { data.append(line) }
        try data.write(to: directory.appending(path: "log.1.jsonl"))
        let store = FileLogStore(directory: directory, maximumFileSize: 0)
        store.write(.sample("own"))
        #expect(await store.records().map(\.message) == ["own"])
    }

    @Test("A record larger than a file is dropped and counted")
    func oversizedRecord() async {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory, maximumFileSize: 0)
        store.write(.sample(String(repeating: "x", count: FileLogStore.fileSizeRange.lowerBound)))
        store.write(.sample("small"))
        #expect(await store.records().map(\.message) == ["small"])
        #expect(store.droppedCount == 1)
    }

    @Test("Records beyond the pending limit are dropped and counted, never queued without bound")
    func pendingLimit() async {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory, maximumFileSize: 0, maximumFileCount: 32, pendingLimit: 0)
        #expect(store.pendingLimit == store.maximumFileSize)
        let padding = String(repeating: "p", count: 2_000)
        // 500 records of about 2 KB fit in the 32 files, so none is lost to rotation: each one
        // is either on disk or counted as dropped.
        for _ in 0..<500 { store.write(.sample(padding)) }
        await store.flush()
        let kept = await store.records().count
        #expect(kept + store.droppedCount == 500)
        #expect(store.writeFailureCount == 0)
    }

    @Test("Parameters are clamped", arguments: [(Int.min, Int.min), (0, 0), (Int.max, Int.max)])
    func clamping(size: Int, count: Int) {
        let store = FileLogStore(directory: temporaryDirectory(), maximumFileSize: size, maximumFileCount: count, pendingLimit: Int.min)
        #expect(FileLogStore.fileSizeRange.contains(store.maximumFileSize))
        #expect(FileLogStore.fileCountRange.contains(store.maximumFileCount))
        #expect(store.pendingLimit >= store.maximumFileSize)
    }

    @Test("removeAll deletes the files; logging starts again afterwards")
    func removeAll() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory)
        store.write(.sample("old"))
        await store.removeAll()
        #expect(await store.records().isEmpty)
        store.write(.sample("new"))
        #expect(await store.records().map(\.message) == ["new"])
    }

    @Test("A folder that cannot be created counts a write failure")
    func unwritableFolder() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let blocker = directory.appending(path: "file")
        try Data("x".utf8).write(to: blocker)
        let store = FileLogStore(directory: blocker.appending(path: "logs"))
        store.write(.sample())
        await store.flush()
        #expect(store.writeFailureCount == 1)
        #expect(await store.records().isEmpty)
    }

    // The simulator has no data protection and reports no protection class, so this runs on
    // devices only.
    #if !os(macOS) && !targetEnvironment(simulator)
    @Test("Files are created with data protection")
    func dataProtection() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FileLogStore(directory: directory)
        store.write(.sample())
        await store.flush()
        let attributes = try FileManager.default.attributesOfItem(atPath: directory.appending(path: "log.jsonl").path(percentEncoded: false))
        #expect(attributes[.protectionKey] as? FileProtectionType == .completeUntilFirstUserAuthentication)
    }
    #endif
}
