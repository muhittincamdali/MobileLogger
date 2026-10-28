import Foundation
import Testing
@testable import MobileLogger

@Suite("MemoryLogStore")
struct MemoryLogStoreTests {
    @Test("The oldest records are dropped at capacity, in order")
    func capacity() {
        let store = MemoryLogStore(capacity: 3)
        for index in 0..<5 { store.write(.sample("m\(index)")) }
        #expect(store.records().map(\.message) == ["m2", "m3", "m4"])
        #expect(store.droppedCount == 2)
    }

    @Test("The byte budget drops old records but always keeps the newest")
    func byteBudget() {
        let store = MemoryLogStore(capacity: 100, maximumBytes: 2_048)
        let large = String(repeating: "x", count: 900)
        for index in 0..<4 { store.write(.sample("\(index)\(large)")) }
        let kept = store.records()
        #expect(kept.count == 1 || kept.count == 2)
        #expect(kept.last?.message.hasPrefix("3") == true)
        #expect(store.byteCount <= 2_048)
        let huge = String(repeating: "y", count: 10_000)
        store.write(.sample(huge))
        #expect(store.records().map(\.message) == [huge])
    }

    @Test("Limits are clamped instead of trapping", arguments: [(Int.min, 1), (0, 1), (-1, 1), (Int.max, MemoryLogStore.largestCapacity)])
    func clamping(requested: Int, expected: Int) {
        let store = MemoryLogStore(capacity: requested, maximumBytes: Int.min)
        #expect(store.capacity == expected)
        #expect(store.maximumBytes == 1_024)
        store.write(.sample())
        #expect(store.records().count == 1)
    }

    @Test("Long runs stay within the limits while the storage is compacted")
    func longRun() {
        let store = MemoryLogStore(capacity: 50)
        for index in 0..<10_000 { store.write(.sample("m\(index)")) }
        let kept = store.records()
        #expect(kept.count == 50)
        #expect(kept.first?.message == "m9950")
        #expect(kept.last?.message == "m9999")
        #expect(store.droppedCount == 9_950)
    }

    @Test("removeAll empties the store and resets the counters")
    func removeAll() {
        let store = MemoryLogStore(capacity: 2)
        for _ in 0..<5 { store.write(.sample()) }
        store.removeAll()
        #expect(store.records().isEmpty)
        #expect(store.droppedCount == 0)
        #expect(store.byteCount == 0)
    }
}
