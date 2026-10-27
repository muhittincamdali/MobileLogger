# Examples

## LogExplorer

A small iOS and macOS app that logs four careless events through MobileLogger (a sign-in with a
password in the message, an API request with a session in the URL and a token in the body, a
payment with a card number and an IBAN, and a failed upload with a bearer token) and lists
what the sinks received. The share button exports the same records as text or JSON Lines. The
app also bootstraps swift-log through `RedactingLogHandler`, so its first record comes from a
swift-log `Logger`.

It uses the package from this checkout (a local package reference to `../..`), so it always
shows the current code.

Run it:

1. Open `Examples/LogExplorer/LogExplorer.xcodeproj` in Xcode 26 or later.
2. Choose the **LogExplorer** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R), then tap the events under **Log an event**.

Launched with the argument `-demo`, the app logs the four events at start; the README
screenshots are taken that way.

From the command line:

```sh
cd Examples/LogExplorer
xcodebuild build -scheme LogExplorer -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme LogExplorer -destination 'platform=macOS'
```

The README samples live in
[`LogExplorer/ReadmeSamples.swift`](LogExplorer/LogExplorer/ReadmeSamples.swift) and
[`LogExplorer/ReadmeSwiftLogSample.swift`](LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift).
The README copies its code from those files, and the package's test targets compile them through
the symlinks `Tests/MobileLoggerTests/ReadmeExamples.swift` and
`Tests/MobileLoggerSwiftLogTests/ReadmeSwiftLogExample.swift`, checking what each sample writes.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](LogExplorer/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.
