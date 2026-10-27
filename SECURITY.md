# Security policy

MobileLogger exists to keep secrets out of logs, so a secret that reaches a sink, a store or an
export is a security issue.

## Supported versions

| Version | Supported |
| ------- | --------- |
| 2.x     | Yes       |
| 1.x     | No        |

## What to report

- A secret that the redactor hides when called directly but that MobileLogger writes: in a
  `LogRecord`, through `OSLogSink`, in a `MemoryLogStore` or `FileLogStore`, or in a
  `LogArchive`.
- A way to make the logger read without bound (memory, time or stack) or crash: a message,
  metadata, URL, body or file in the store's folder that does so.
- A way for logged text to forge records in an export, or for an export file name to leave
  its folder.

A secret that `SensitiveDataRedactor` itself does not hide belongs to the redaction spec and
its reference implementation. Report it to
[iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools/security) instead; check
first whether the spec lists it as a known limit (the
[Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules)
article summarises them).

## How to report

Use [private vulnerability reporting](https://github.com/muhittincamdali/MobileLogger/security/advisories/new)
on GitHub. Do not open a public issue. Include the code that logs, the policy, what was written
and the platform. Never include a real secret: a made-up value of the same shape shows the
problem just as well.

You will get an answer within seven days. Fixes are released as a patch version and noted in
the [changelog](CHANGELOG.md).
