# Getting started

Add the package, make a logger, and write messages whose data is in the metadata.

## Overview

This article takes an app from no logging to logs that are redacted, kept on the device and
ready to export. Each step builds on the one before.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/MobileLogger.git` and add the **MobileLogger** library to
your app target. Add **MobileLoggerSwiftLog** too if your app or its packages use swift-log.

In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/MobileLogger.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "MobileLogger", package: "MobileLogger")
    ])
]
```

### Make one logger per feature

A ``MobileLogger/MobileLogger`` is a value; make it once and use it anywhere. The category is
how Console.app and an export group its messages.

```swift
import MobileLogger

extension MobileLogger {
    static let checkout = MobileLogger(category: "Checkout")
    static let network = MobileLogger(category: "Network")
}
```

By default a logger writes to unified logging (``OSLogSink``) and drops `trace` messages. Pass
`minimumLevel:` to change that.

### Put data in the metadata

The message is free text, and free text is read with a single cut point: the first key that is
not allowed, or the first secret name, hides the rest of the message. Keep the message a
constant sentence and put values in the metadata, where each key is judged on its own:

```swift
MobileLogger.checkout.info("Signed in user=alice")
// Signed in user=[redacted]

MobileLogger.checkout.info("Signed in", metadata: ["user": "alice", "attempt": 2])
// Signed in {"attempt":2,"user":"alice"}
```

A key that names a secret (`password`, `token`, `api_key`, `session_id`, `card`, …) or is not
plain ASCII hides its value whatever it holds. The values under the other keys are scanned for
card numbers, IBANs, email addresses and tokens. <doc:RedactionRules> has the full list.

### Log URLs and bodies with their own types

``LogValue/url(_:)`` and ``LogValue/body(_:contentType:)`` read a URL or an HTTP body with the
parser the spec prescribes, so an identifier in a path becomes `:id`, user name, password and
fragment are dropped, and a JSON, form or multipart body keeps its structure with secrets
hidden:

```swift
MobileLogger.network.info("Request finished", metadata: [
    "url": .url(request.url!),
    "status": .int(response.statusCode),
    "response": .body(data, contentType: response.mimeType),
])
```

### Keep the logs and export them

Add a store as a sink to read the records back, then make a ``LogArchive`` when the user sends
a bug report:

```swift
let store = FileLogStore()
let log = MobileLogger(category: "App", sinks: [OSLogSink(), store])

let archive = try await LogArchive.make(from: store, format: .text, minimumLevel: .info)
```

<doc:ExportingLogs> shows `ShareLink` and the limits of each store.

### Route swift-log through the redactor

Packages that log with swift-log can go through the same redactor and stores. Bootstrap
swift-log once, early in the app's life:

```swift
import Logging
import MobileLogger
import MobileLoggerSwiftLog

let base = MobileLogger(sinks: [OSLogSink(), store])
LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }
```

Each swift-log label becomes a category; swift-log's metadata of every kind is redacted with the
message.
