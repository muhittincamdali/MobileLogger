# Exporting logs

Keep recent logs on the device within fixed limits and let the user share them with a bug
report.

## Overview

Unified logging is the right place for logs while you debug, but a user who reports a problem
cannot easily send you a sysdiagnose. MobileLogger's stores keep the records your app logged,
already redacted, so you can attach them to a report.

### Choose a store

``MemoryLogStore`` keeps the newest records in memory: at most ``MemoryLogStore/capacity``
records (1,000 by default) and about ``MemoryLogStore/maximumBytes`` bytes (4 MiB). The oldest
are dropped first, and ``MemoryLogStore/droppedCount`` says how many. Use it for an in-app log
screen and for the last minutes before a report.

``FileLogStore`` keeps records across launches in JSON Lines files: `log.jsonl` for the newest,
then `log.1.jsonl` and so on. When the newest file reaches ``FileLogStore/maximumFileSize``
(1 MiB) the files move up by one and the oldest is deleted, so the store never takes more than
``FileLogStore/maximumFileSize`` × ``FileLogStore/maximumFileCount`` (4 MiB by default). Writes
happen on a background queue; when the disk falls behind, records beyond
``FileLogStore/pendingLimit`` are dropped and counted rather than held in memory.

```swift
let memory = MemoryLogStore(capacity: 2_000)
let disk = FileLogStore(maximumFileSize: 512 * 1_024, maximumFileCount: 8)
let log = MobileLogger(category: "App", sinks: [OSLogSink(), memory, disk])
```

The default folder of ``FileLogStore`` is `Library/Caches/MobileLogger`: it is not backed up and
the system may empty it when space runs low. On iOS, tvOS, watchOS and visionOS the files are
created with the `completeUntilFirstUserAuthentication` protection class.

### Make an archive

``LogArchive`` turns records into a file. Filter by level and date, and pick a format:

- ``LogExportFormat/jsonLines``: one JSON object per line, for `jq` and log tools;
- ``LogExportFormat/text``: one readable line per record.

```swift
let archive = try await LogArchive.make(
    from: disk, format: .text, minimumLevel: .info, since: Date().addingTimeInterval(-3_600)
)
```

The text format starts each record with its date, level and category:

```text
2026-10-28T09:41:07.250Z [info] Network: Request finished {"status":200,"url":"https://api.example.com/users/:id"}
```

A line break inside a message is followed by four spaces in the text format, so a logged
message cannot write a line that looks like a record of its own.

### Share it

``LogArchive`` conforms to `Transferable`, so `ShareLink` can offer it directly:

```swift
struct ReportButton: View {
    let archive: LogArchive

    var body: some View {
        ShareLink(item: archive, preview: SharePreview(archive.fileName)) {
            Label("Send logs", systemImage: "square.and.arrow.up")
        }
    }
}
```

To attach the file yourself, write it to a folder with ``LogArchive/write(to:)``. File names keep
only ASCII letters, digits, `.`, `_` and `-`, so a name cannot point into another folder.

### Write your own sink

A sink is any type that conforms to ``LogSink``. It receives ``LogRecord`` values that are
already redacted, on the thread that logs:

```swift
struct BreadcrumbSink: LogSink {
    let add: @Sendable (String) -> Void

    func write(_ record: LogRecord) {
        guard record.level >= .warning else { return }
        add("\(record.category): \(record.message)")
    }
}
```

Keep ``LogSink/write(_:)`` fast. Do slow work on a queue of your own, with a limit on what may
wait, as ``FileLogStore`` does.
