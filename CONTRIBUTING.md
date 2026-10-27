# Contributing

Thanks for taking the time to improve MobileLogger.

## Reporting bugs

Open an issue with:

- the code that logs (message, metadata and `RedactionPolicy`),
- what was written and what you expected,
- platform and OS version, and Xcode version.

**Do not open a public issue for a secret that gets through the redactor.** Report it privately
as described in the [security policy](SECURITY.md).

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change.
3. Run the tests on macOS and on an iPhone simulator:

    ```sh
    swift test
    xcodebuild test -scheme MobileLogger-Package \
      -destination 'platform=iOS Simulator,name=iPhone 17'
    ```

4. Redaction rules belong to the shared redaction spec and its reference implementation in
   [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools); propose rule changes
   there. A change in this package must keep `ProbeCorpusTests` and `SpecConformanceTests`
   green: the logger has to write exactly what the reference redactor writes.
5. If you change logic (the metadata pipeline, a store, the export), add or update a test in
   `Tests/MobileLoggerTests`. Every new limit must fail closed: hide or drop more, never less.
6. If you change a README code sample, change the copy in
   `Examples/LogExplorer/LogExplorer/ReadmeSamples.swift` (or `ReadmeSwiftLogSample.swift`) as
   well. Those files are what gets compiled: by the example app, and by `swift test` through the
   symlinks in the test targets, which also check each sample's output. Build the app with:

    ```sh
    cd Examples/LogExplorer
    xcodebuild build -scheme LogExplorer -destination 'generic/platform=iOS Simulator'
    ```

7. If a change affects the example app's screen, regenerate the screenshots with
   `scripts/capture-example-screens.sh`.
8. `README.md` will have translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI fails while a translation is behind. If you change `README.md`
   and cannot update the translations, say so in the pull request.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode; new code should not add warnings.
- Document public API with DocC comments (`///`).
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## License

By contributing you agree that your contributions are licensed under the MIT License.
