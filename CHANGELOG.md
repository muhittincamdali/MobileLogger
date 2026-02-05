# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Datadog destination for APM integration
- Elasticsearch destination for centralized logging
- File rotation with size and date policies
- Log aggregation for batch processing
- Full-text log search with filtering
- JSON formatter for machine-readable output
- Analytics integration module

## [1.0.0] - 2024-01-15

### Added
- Multi-destination logging architecture (console, file, OSLog, remote)
- Five log levels: debug, info, warning, error, critical
- Structured logging with key-value metadata support
- OSLog integration for Console.app compatibility
- Remote logging with configurable batch size and flush interval
- File-based log persistence
- Privacy redaction for PII/sensitive data filtering
- Crash reporter with signal handling
- Performance tracker for operation timing
- Pretty formatter for human-readable output
- Log formatter protocol for custom formatting
- Log exporter for sharing and analysis
- Device context auto-capture (OS, app version, device model)
- Thread-safe logging with actor isolation
- Source location tracking (file, function, line)

### Features
- Zero dependencies — pure Swift implementation
- Protocol-oriented destination design
- iOS 15+, macOS 13+, tvOS 15+, watchOS 8+ support
- Swift Package Manager distribution

[Unreleased]: https://github.com/muhittincamdali/MobileLogger/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/muhittincamdali/MobileLogger/releases/tag/v1.0.0
