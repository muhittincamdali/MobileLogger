# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-28

A rewrite around one job: logs that are safe to keep on the device and to export. The 1.x API
(`Log`, the circuit breaker, retry policy, event bus, PII scrubber and remote log mirror) is
removed; nothing of it is kept.

### Added

- `MobileLogger`, a `Sendable` logger with seven levels (`trace` to `critical`, the levels of
  swift-log), base metadata, a `RedactionPolicy` and sinks. Messages and metadata are evaluated
  only for enabled levels.
- Redaction of every message, metadata key and value, URL and HTTP body with
  `SensitiveDataRedactor` from iOSSecurityTools 2.1.2, the reference implementation of
  REDACTION-SPEC 2.1-r2, with every detector on. `RedactionPolicy` can allow text keys and query
  parameters, choose host-only URLs and change the size limits; it cannot switch the
  secret-name rule off.
- `LogValue` with `.url` and `.body(_:contentType:)` cases, read by the spec's URL and body
  parsers, and `LogValue.error(_:)`.
- `LogRecord` and `RedactedValue`: what sinks receive, already redacted.
- `OSLogSink`, which writes the redacted line to unified logging as public.
- `MemoryLogStore` (record count and byte budget) and `FileLogStore` (rotating JSON Lines files
  with a size, file count and pending-bytes limit, data protection outside macOS).
- `LogArchive` and `LogExportFormat`: JSON Lines or text exports filtered by level and date,
  `Transferable` for `ShareLink`, with sanitised file names.
- The `MobileLoggerSwiftLog` product with `RedactingLogHandler`, a swift-log `LogHandler`.
- The LogExplorer example app for iOS and macOS, a DocC catalog with four articles, and CI
  through the shared workflows of muhittincamdali/.github.

### Changed

- Minimum platforms: iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2; Swift 6.2 tools and
  the Swift 6 language mode.

### Removed

- The 1.x sources and their CocoaPods spec. MobileLogger 2.0 depends on a Swift package that
  has no pod, so it is distributed with Swift Package Manager only.

### Security

- Limits fail closed: a message over 64 KiB is hidden unread; metadata nested more than 64
  levels, larger than the body limit, or holding more than the body limit of URLs and bodies
  (counted at full size) is omitted before it is copied or read; a URL longer than the body
  limit is hidden whole; stores drop and count records instead of growing.
- NaN and infinity in metadata are written as strings instead of raising in
  `JSONSerialization`, and integers of 13 digits or more, including `Int.min`, are written as
  strings so the card number detector reads them.
- The text export indents every line break inside a record, so a logged message cannot forge
  a record line.
- A held name hides the value beside it when both are URLs or bodies, as it does when both are
  strings: `[[.body("password"), .body("hunter2")]]` and
  `["label": .body("password"), "value": .url(…)]` hide the value. The second metadata pass puts
  a word that names a secret in place of each URL or body whose text names one, so it sees the
  same names as the first.

## [1.0.0] - 2026-02-03

First release.

[Unreleased]: https://github.com/muhittincamdali/MobileLogger/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/MobileLogger/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/MobileLogger/releases/tag/v1.0.0
