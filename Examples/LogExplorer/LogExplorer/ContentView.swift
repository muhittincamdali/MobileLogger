import MobileLogger
import SwiftUI

struct ContentView: View {
    let diagnostics: Diagnostics
    @State private var format = LogExportFormat.text

    var body: some View {
        NavigationStack {
            List {
                Section("Log an event") {
                    ForEach(SampleEvent.allCases) { event in
                        Button {
                            diagnostics.log(event)
                        } label: {
                            Label(event.rawValue, systemImage: event.systemImage)
                        }
                    }
                }
                Section {
                    if diagnostics.records.isEmpty {
                        Text("Nothing logged yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(diagnostics.records) { record in
                        RecordRow(record: record)
                    }
                } header: {
                    Text("What the sinks received")
                } footer: {
                    Text("Every record was redacted before any sink saw it, so the export below holds the same text.")
                }
            }
            .navigationTitle("Log Explorer")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    let archive = diagnostics.archive(format: format)
                    ShareLink(item: archive, preview: SharePreview(archive.fileName)) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Picker("Format", selection: $format) {
                        Text("Text").tag(LogExportFormat.text)
                        Text("JSON Lines").tag(LogExportFormat.jsonLines)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive) {
                        Task { await diagnostics.clear() }
                    }
                }
            }
        }
    }
}

/// One record: level, category, message and metadata, as an export writes them.
struct RecordRow: View {
    let record: LogRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.level.rawValue.uppercased())
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(levelColor.opacity(0.18), in: .capsule)
                    .foregroundStyle(levelColor)
                Text(record.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(record.date, format: .dateTime.hour().minute().second())
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(record.message)
                .font(.callout)
            if let metadata = metadataText {
                Text(metadata)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var levelColor: Color {
        switch record.level {
        case .trace, .debug: .gray
        case .info, .notice: .blue
        case .warning: .orange
        case .error, .critical: .red
        }
    }

    private var metadataText: String? {
        if let omitted = record.omittedMetadata { return omitted }
        guard !record.metadata.isEmpty else { return nil }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes, .prettyPrinted]
        return (try? encoder.encode(record.metadata)).flatMap { String(data: $0, encoding: .utf8) }
    }
}
