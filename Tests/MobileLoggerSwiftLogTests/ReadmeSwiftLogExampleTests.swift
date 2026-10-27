import MobileLogger
import Testing

/// The swift-log sample of the README (`ReadmeSwiftLogExample.swift`, a symlink to the example
/// app's file) writes what its comment says. It bootstraps swift-log, which a process may do
/// only once, so it is the only test that does.
@Test("README swift-log sample: the token is hidden, the rest kept")
func readmeSwiftLogSample() throws {
    let store = MemoryLogStore()
    bootstrapSwiftLog(store: store)
    let record = try #require(store.records().first)
    #expect(record.category == "com.example.sync")
    #expect(record.message == "Sync finished")
    #expect(record.metadata == ["items": .string("42"), "token": .string("[redacted]")])
}
