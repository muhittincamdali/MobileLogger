# Choosing a logger

When MobileLogger fits, and when swift-log, Pulse, CocoaLumberjack or `os.Logger` alone is the
better choice.

## Overview

MobileLogger does one thing other logging libraries leave to you: it redacts everything before
it is written, so logs can be kept on the device and sent by users. It is not a replacement for
every logging tool, and it works alongside the most common one, swift-log.

### Use MobileLogger when

- logs leave the device: users send them with bug reports, or support asks for them;
- the people who log are many and in a hurry, and you want a safety net under every call,
  including the ones in third-party packages that use swift-log;
- you need to show that logging follows a written redaction spec, with tests.

### Use `os.Logger` alone when

Logs only ever stay in unified logging and you mark each interpolated value's privacy yourself.
`os.Logger` hides dynamic values as `<private>` outside the debugger, which is safe, but those
logs are then of little use in a sysdiagnose, and nothing hides a secret written into the
static part of a message.

### Use swift-log when

You write a library. Libraries should log through swift-log's `Logger` and let the app choose
the handler. Apps that use MobileLogger then route those logs through the redactor with
`RedactingLogHandler`. swift-log is also the choice on Linux servers, where MobileLogger does
not run.

### Use Pulse when

You want to inspect network traffic: request and response timelines, a console UI inside the
app and on the Mac. Pulse can redact HTTP headers, query items and JSON fields
you name; it does not redact messages. MobileLogger has no network inspector and no UI beyond
the example app.

### Use CocoaLumberjack when

You maintain an Objective-C or mixed code base that already uses it, or you need its formatter
and logger ecosystem. It has rolling file logs and file protection, but no redaction.

### Combine them

MobileLogger's sinks are a protocol, so it can feed other tools: a ``LogSink`` can pass
redacted records to a crash reporter's breadcrumbs or to your own upload queue. In the other
direction, swift-log's `LoggingSystem` can bootstrap a multiplex handler that sends each
message both to MobileLogger and to another handler.
