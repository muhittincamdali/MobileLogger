import MobileLogger
import SwiftUI

/// Logs sample events through MobileLogger and shows what the sinks received: the redacted
/// records, ready to export with the share button.
@main
struct LogExplorerApp: App {
    @State private var diagnostics = Diagnostics()

    var body: some Scene {
        WindowGroup {
            ContentView(diagnostics: diagnostics)
        }
    }
}

/// The app's logging set-up: unified logging, an in-memory store for the screen and a file
/// store that survives relaunches.
@MainActor
@Observable
final class Diagnostics {
    let memory = MemoryLogStore(capacity: 500)
    let disk = FileLogStore()
    let log: MobileLogger
    private(set) var records: [LogRecord] = []

    init() {
        log = MobileLogger(category: "LogExplorer", minimumLevel: .debug, sinks: [OSLogSink(), memory, disk])
        bootstrapSwiftLog(store: memory)
        if ProcessInfo.processInfo.arguments.contains("-demo") {
            for event in SampleEvent.allCases { event.log(with: log) }
        }
        refresh()
    }

    func log(_ event: SampleEvent) {
        event.log(with: log)
        refresh()
    }

    func refresh() {
        records = memory.records().reversed()
    }

    func clear() async {
        memory.removeAll()
        await disk.removeAll()
        refresh()
    }

    func archive(format: LogExportFormat) -> LogArchive {
        LogArchive(records: memory.records(), format: format)
    }
}
