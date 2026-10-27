<!-- i18n-source: README.md@38e5797342414cc5d17bf60a55cbbb922bd32ae1 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

MobileLogger ist ein Swift-Paket für strukturiertes Logging in iOS-, macOS-, tvOS-, watchOS- und visionOS-Apps, das Geheimnisse verbirgt, bevor irgendetwas geschrieben wird. Jede Nachricht und jeder Metadata-Wert läuft durch den Redactor einer gemeinsamen, schriftlich festgehaltenen Redaction-Spezifikation, sodass Unified Logging, die Speicher auf dem Gerät und eine exportierte Datei denselben unbedenklichen Text enthalten. Es richtet sich an App-Teams, deren Logs das Gerät verlassen: angehängt an Fehlerberichte, vom Support verschickt oder aus einem sysdiagnose gelesen. Es schreibt in `os.Logger`, hält Logs innerhalb fester Grenzen im Speicher oder auf der Festplatte, exportiert sie für `ShareLink` und schwärzt auch die Logs von Paketen, die swift-log verwenden.

## Highlights

- **Schwärzung auf jedem Pfad** — Nachrichten, Metadata-Schlüssel und -Werte, URLs und HTTP-Bodys laufen durch `SensitiveDataRedactor` aus [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools), der Referenzimplementierung der Redaction-Spezifikation: Namen von Geheimnissen, Kartennummern (Luhn), IBANs (mod-97), E-Mail-Adressen, JSON Web Tokens, Bearer- und lange Tokens.
- **An der Spezifikation geprüft** — der vorgeschriebene Testsatz der Spezifikation und ihr Korpus aus 7.866 feindlichen Eingaben laufen über die eigenen Einstiegspunkte des Loggers; die Ausgabe muss für jede Eingabe der des Referenz-Redactors entsprechen, und der Export darf nichts hinzufügen, was er verbirgt.
- **Fail-closed-Grenzen** — zu große Nachrichten, Metadata mit mehr als 64 Ebenen Verschachtelung, über 256 KiB oder mit mehr als 256 KiB an URLs und Bodys sowie zu lange URLs werden vollständig verborgen, statt halb gelesen zu werden; NaN, Unendlich und `Int.min` lösen nie einen Trap aus.
- **Begrenzte Speicher** — `MemoryLogStore` behält die neuesten Einträge innerhalb eines Anzahl- und eines Byte-Budgets, `FileLogStore` rotiert eine feste Anzahl von JSON-Lines-Dateien, und beide zählen, was sie verwerfen, statt immer weiter zu wachsen.
- **Export, bereit zum Teilen** — `LogArchive` schreibt JSON Lines oder Text, nach Level und Datum gefiltert, und entspricht `Transferable` für `ShareLink`.
- **swift-log-Brücke** — `RedactingLogHandler` leitet die Logs jedes Pakets, das swift-log verwendet, durch denselben Redactor und dieselben Speicher.

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Füge sie in das Suchfeld oben rechts im Fenster ein. Lass **Dependency Rule** auf **Up to Next Major Version** ab `2.0.0` und klicke auf **Add Package**. Wähle im nächsten Fenster neben **MobileLogger** dein App-Target aus und klicke erneut auf **Add Package**.

**2. Modul importieren**

```swift
import MobileLogger
```

Setze diese Zeile an den Anfang der Swift-Datei, in der du loggst.

**3. Verwenden**

Lege pro Funktion einen Logger an und logge eine Nachricht, deren Daten in der Metadata stehen:

```swift
import MobileLogger

extension MobileLogger {
    /// One logger per feature; make it once and use it anywhere.
    static let checkout = MobileLogger(category: "Checkout")
}

func quickStart() {
    MobileLogger.checkout.info("Payment sent", metadata: [
        "status": 200,
        "note": "paid with 4242 4242 4242 4242",
        "email": "alice@example.com",
        "password": "hunter2",
    ])
    // Xcode's console and Console.app show:
    // Payment sent {"email":"a•••@example.com","note":"paid with •••• 4242","password":"[redacted]","status":200}
}
```

Rufe `quickStart()` über einen Button oder `.task` auf, starte die App und sieh dir die Xcode-Konsole an.

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/MobileLogger.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "MobileLogger", package: "MobileLogger"),
        // Only if the app or its packages log with swift-log:
        .product(name: "MobileLoggerSwiftLog", package: "MobileLogger"),
    ])
]
```

Das Paket hängt von [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) (dem Redactor) und [swift-log](https://github.com/apple/swift-log) (wird nur vom Produkt `MobileLoggerSwiftLog` verwendet) ab.

## Verwendung

Die folgenden Beispiele sind aus [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) und [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift) kopiert, die die Beispiel-App und die Tests kompilieren; die Tests prüfen jede Ausgabe in den Kommentaren.

### Nachrichten und Metadata schreiben

Eine Nachricht ist Freitext mit genau einer Schnittstelle: Der erste nicht erlaubte Schlüssel oder der erste Name eines Geheimnisses verbirgt den Rest. Halte die Nachricht als gleichbleibenden Satz und lege Werte in die Metadata, wo jeder Schlüssel für sich beurteilt wird.

```swift
func messagesAndMetadata(log: MobileLogger) {
    // A message is free text: the first key that is not allowed hides the rest of it.
    log.info("Signed in user=alice")                  // Signed in user=[redacted]
    log.info("GET /orders status=200 duration_ms=41") // kept: status, duration_ms are allowed

    // Metadata keeps values under keys that name no secret.
    log.info("Signed in", metadata: ["user": "alice", "attempt": 2])
    // Signed in {"attempt":2,"user":"alice"}
}
```

### URLs und HTTP-Bodys loggen

`.url` entfernt Benutzername, Passwort und Fragment, ersetzt Kennungen im Pfad durch `:id` und verbirgt Query-Werte. `.body` liest JSON-, Formular-, Multipart- und Klartext-Bodys anhand ihres Content-Types und lässt jeden anderen Body weg.

```swift
func urlsAndBodies(log: MobileLogger) {
    let url = URL(string: "https://bob:pw@api.example.com/users/12345678/orders?page=2#top")!
    let body = Data(#"{"id":7,"access_token":"eyJhbGciOiJIUzI1NiJ9.e30.x","items":3}"#.utf8)
    log.info("Request finished", metadata: [
        "url": .url(url),
        "status": 200,
        "response": .body(body, contentType: "application/json"),
    ])
    // Request finished {"response":"{\"id\":7,\"access_token\":\"[redacted]\",\"items\":3}",
    //   "status":200,"url":"https://api.example.com/users/:id/orders?page=[redacted]"}
}
```

### Logs aufbewahren und exportieren

```swift
func storesAndExport() async throws -> LogArchive {
    let memory = MemoryLogStore(capacity: 2_000)
    let disk = FileLogStore() // Library/Caches/MobileLogger, 4 files of 1 MiB
    let log = MobileLogger(category: "Sync", sinks: [OSLogSink(), memory, disk])

    log.error("Upload failed", metadata: ["error": .error(URLError(.timedOut)), "attempt": 3])

    // Everything a store holds was redacted when it was logged.
    return try await LogArchive.make(from: disk, format: .text, minimumLevel: .warning)
}
```

Übergib das Archiv an `ShareLink(item: archive, preview: SharePreview(archive.fileName))` oder schreibe es mit `archive.write(to:)` in einen Ordner.

### swift-log durch den Redactor leiten

```swift
/// Sends the logs of every package that uses swift-log through the redactor. Call it once,
/// early in the app's life: swift-log accepts one bootstrap per process.
func bootstrapSwiftLog(store: MemoryLogStore) {
    let base = MobileLogger(sinks: [OSLogSink(), store])
    LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }

    let logger = Logger(label: "com.example.sync")
    logger.info("Sync finished", metadata: ["token": "abc123", "items": "42"])
    // Sync finished {"items":"42","token":"[redacted]"}
}
```

### Mehr erlauben, wo du es brauchst

Die Standardwerte verbergen am meisten. Eine `RedactionPolicy` kann mehr durchlassen, aber sie kann die Regel für Namen von Geheimnissen und die Detektoren nicht abschalten.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## Wann etwas anderes besser passt

| Du brauchst                                                  | Verwende                                                                                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| Eine Logging-API für eine Bibliothek, die du veröffentlichst | [swift-log](https://github.com/apple/swift-log); Apps leiten es dann über `RedactingLogHandler`                                 |
| Einen Netzwerk-Inspektor mit Konsolenoberfläche              | [Pulse](https://github.com/kean/Pulse); er schwärzt nur Header, Query-Items und JSON-Felder, die du benennst, keine Nachrichten |
| Logs, die Unified Logging nie verlassen                      | `os.Logger` mit `privacy:` an jeder Interpolation                                                                               |
| Eine Objective-C-Codebasis, die es schon verwendet           | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                           |
| Logging auf Linux-Servern                                    | swift-log mit einem Server-Handler; MobileLogger nutzt OSLog und läuft nur auf Apple-Plattformen                                |

Der Artikel [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) erklärt jeden Fall und wie man sie kombiniert.

## Demo

| Hell                                                                                | Dunkel                                                                               |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| ![LogExplorer zeigt geschwärzte Einträge, hell](docs/images/log-explorer-light.png) | ![LogExplorer zeigt geschwärzte Einträge, dunkel](docs/images/log-explorer-dark.png) |

Die Beispiel-App [LogExplorer](Examples/LogExplorer) loggt vier Ereignisse mit Geheimnissen, so wie Apps es oft versehentlich tun, und listet auf, was ihre Sinks erhalten haben. Öffne `Examples/LogExplorer/LogExplorer.xcodeproj` in Xcode, wähle einen iPhone-Simulator oder **My Mac**, drücke **Run** und logge Ereignisse mit dem **+**-Button; der Teilen-Button exportiert sie. Die Screenshots nimmt [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) aus der App auf; [Examples/README.md](Examples/README.md) enthält die Details.

## Dokumentation

API-Referenz und Artikel:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — jeder öffentliche Typ, mit DocC erzeugt und vom Dokumentations-Workflow veröffentlicht.
- Die Redaction-Spezifikation, der das Paket folgt, ist in [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) umgesetzt und dokumentiert.

## Anleitungen

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — vom Hinzufügen des Pakets bis zu Logs, die geschwärzt, aufbewahrt und exportiert werden.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — wie Nachrichten, Metadata, URLs und Bodys gelesen werden und was nicht erkannt wird.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — Speichergrenzen, Archivformate, `ShareLink` und eigene Sinks.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — wann `os.Logger`, swift-log, Pulse oder CocoaLumberjack besser passt.

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| Toolchain | Swift 6.2 · Xcode 26+ |

CI baut mit dem Standard-Xcode des `macos-26`-Runner-Images von GitHub. Das Paket wird mit Xcode 27 entwickelt.

## Architektur

```text
log.info(message, metadata)
  └─ MobileLogger ── level check, then RecordRedactor
       ├─ message   → SensitiveDataRedactor.redact(_:)          free text, one cut point
       ├─ metadata  → one JSON object → redact(body:"application/json")
       │    ├─ .url  → redact(url:)    put back only where its key keeps it
       │    └─ .body → redact(body:contentType:)
       └─ LogRecord (redacted) → every LogSink
            ├─ OSLogSink        os.Logger, public
            ├─ MemoryLogStore   count + byte budget
            └─ FileLogStore     rotating JSON Lines → LogArchive → ShareLink
```

- `Sources/MobileLogger` enthält den Logger, die Eintragstypen, die Sinks (`Sinks/`) und den Export (`Export/`). `Sources/MobileLoggerSwiftLog` enthält den swift-log-Handler, ein eigenes Produkt, damit Apps ohne swift-log ihn nicht mitlinken.
- Die Schwärzung geschieht einmal, auf dem Thread, der loggt, bevor ein Sink aufgerufen wird. Sinks sehen immer nur `LogRecord`-Werte, sodass ein neuer Sink nichts preisgeben kann, was der Redactor verborgen hat.
- URLs und Bodys werden zuerst von ihren eigenen Parsern geschwärzt. Danach wird das Metadata-JSON mit diesem Text an ihrer Stelle gelesen, sodass eine URL oder ein Body seine Nachbarn verbirgt wie jeder andere String, und ein zweites Mal mit einem Ersatzwort an ihrer Stelle: einem Wort, das ein Geheimnis benennt, wo der Text seinen Nachbarn eines benennt, sonst einem neutralen Platzhalter. Nur wo dieses Wort unverändert zurückkommt (sein Schlüssel und seine Nachbarn verbergen nichts), bleibt der Text der URL bzw. des Bodys erhalten; überall sonst bleibt der Wert verborgen. Ein Paar aus zwei Bodys, deren erster `password` lautet, verbirgt daher den zweiten, wie ein Paar aus zwei Strings.
- Jede Grenze ist fail-closed: Wird sie überschritten, verbirgt oder verwirft der Logger mehr, nie weniger, und zählt, was er verwirft.
- Die Tests verwenden Swift Testing und laufen auf macOS und in einem iPhone-Simulator: der vorgeschriebene Satz und der Korpus der Spezifikation, die Metadata-Pipeline, die Speicher, der Export, die swift-log-Brücke, die README-Beispiele und ein Rundlauf durch Unified Logging mit `OSLogStore`.

Führe die Tests lokal aus:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roadmap

- Ein fertiger SwiftUI-Log-Viewer, aufgebaut auf der Liste der Beispiel-App.
- Zeitbasierte Aufbewahrung für `FileLogStore`, neben den Grenzen für Größe und Anzahl.
- Das Paket zum Swift Package Index hinzufügen; `.spi.yml` liegt bereits im Repository.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
