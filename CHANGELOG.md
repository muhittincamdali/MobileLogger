# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CloudKit destination for synced logging

## [1.0.0] - 2025-01-15

### Added
- Six log levels (trace, debug, info, warning, error, critical)
- ConsoleDestination with colored output
- FileDestination with rotation support
- OSLogDestination for Apple unified logging
- RemoteDestination for HTTP log shipping
- JSONFormatter for structured output
- PrettyFormatter for human-readable logs
- PrivacyRedactor for PII masking
- @Sensitive property wrapper
- PerformanceTracker for execution timing
- CrashReporter for exception/signal handling
- Thread-safe logging with serial queue
- Zero external dependencies

### Changed
- Optimized batch processing for remote destination

### Fixed
- File rotation edge cases

[Unreleased]: https://github.com/muhittincamdali/MobileLogger/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/muhittincamdali/MobileLogger/releases/tag/v1.0.0
