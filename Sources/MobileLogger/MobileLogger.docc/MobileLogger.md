# ``MobileLogger``

Structured logging for Apple apps that hides secrets before anything is written, keeps logs on
the device within fixed limits and exports them as a file you can share.

## Overview

A log line written in a hurry carries what the app had at hand: a password in a form, a token
in a header, a card number in a payment response. MobileLogger runs every message and every
metadata value through the redactor of a shared redaction spec before any destination sees it,
so unified logging, the in-app stores and an exported file all hold the same safe text.

```swift
import MobileLogger

let store = MemoryLogStore()
let log = MobileLogger(category: "Checkout", sinks: [OSLogSink(), store])

log.info("Payment sent", metadata: [
    "status": 200,
    "note": "paid with 4242 4242 4242 4242",
    "password": "hunter2",
])
// Payment sent {"note":"paid with •••• 4242","password":"[redacted]","status":200}
```

The redactor is `SensitiveDataRedactor` from
[iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools), the reference
implementation of the spec. MobileLogger adds what a logger needs around it: levels, structured
metadata with URLs and HTTP bodies, sinks, bounded stores, an export format and a bridge for
packages that log through swift-log (the `MobileLoggerSwiftLog` product).

Redaction is a safety net for mistakes, not a guarantee. Keep secrets out of log calls in the
first place; <doc:RedactionRules> lists what is found and what is not.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:RedactionRules>
- <doc:ExportingLogs>
- <doc:ChoosingALogger>

### Logging

- ``MobileLogger/MobileLogger``
- ``LogLevel``
- ``LogValue``
- ``LogMetadata``
- ``RedactionPolicy``

### Records and sinks

- ``LogRecord``
- ``RedactedValue``
- ``LogSink``
- ``OSLogSink``

### Keeping and exporting logs

- ``LogRecordSource``
- ``MemoryLogStore``
- ``FileLogStore``
- ``LogArchive``
- ``LogExportFormat``
