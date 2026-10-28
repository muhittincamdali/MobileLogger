import iOSSecurityTools

/// What the redactor may let through, beyond the defaults of the redaction spec.
///
/// The defaults hide the most: free text is read on only after the keys `status`, `method`,
/// `path`, `duration_ms` and `count`, no query value of a URL is kept, and every value detector
/// (card numbers, IBANs, email addresses, JSON Web Tokens, bearer tokens and long tokens) is on.
/// The detectors cannot be switched off: without the secret-name rule a logger would write
/// `password=hunter2` as it is.
///
/// ```swift
/// let policy = RedactionPolicy(
///     allowedTextKeys: ["screen", "attempt"],
///     allowedQueryParameters: ["page", "sort"]
/// )
/// let log = MobileLogger(category: "Catalog", policy: policy)
/// ```
public struct RedactionPolicy: Sendable {
    /// How much of a URL is recorded.
    public enum URLDetail: Sendable, Hashable {
        /// Scheme, host, port, path and query, redacted.
        case full
        /// Scheme, host and port only.
        case hostOnly
    }

    /// The default of ``maximumMessageBytes``: 64 KiB.
    public static let defaultMaximumMessageBytes = 65_536

    /// The default of ``maximumBodySize``: 256 KiB, the limit of the redaction spec.
    public static let defaultMaximumBodySize = SensitiveDataRedactor.defaultMaximumBodySize

    /// The text written in place of a hidden value: `[redacted]`.
    public static let replacement = SensitiveDataRedactor.replacement

    /// Keys after which free text is read on, in addition to `status`, `method`, `path`,
    /// `duration_ms` and `count`. A key that is not plain ASCII or names a secret is ignored.
    public let allowedTextKeys: [String]
    /// Query parameters whose values a ``LogValue/url(_:)`` keeps. Free text never uses them.
    public let allowedQueryParameters: [String]
    /// How much of a URL is recorded.
    public let urlDetail: URLDetail
    /// The largest body, and the largest metadata as JSON, that is read, in bytes. A larger one
    /// is omitted unread. The URLs and bodies in one message's metadata may not be larger than
    /// this together either, counted at full size.
    public let maximumBodySize: Int
    /// The longest message, in UTF-8 bytes, that is read. A longer message is replaced by
    /// `[redacted]` without being read, so one huge string cannot stall the app.
    public let maximumMessageBytes: Int

    /// Creates a policy.
    ///
    /// - Parameters:
    ///   - allowedTextKeys: Keys after which free text is read on.
    ///   - allowedQueryParameters: Query parameters whose values URLs keep.
    ///   - urlDetail: How much of a URL is recorded.
    ///   - maximumBodySize: The largest body or metadata that is read, in bytes; negative values
    ///     count as 0.
    ///   - maximumMessageBytes: The longest message that is read, in UTF-8 bytes; negative values
    ///     count as 0.
    public init(
        allowedTextKeys: [String] = [], allowedQueryParameters: [String] = [], urlDetail: URLDetail = .full,
        maximumBodySize: Int = defaultMaximumBodySize, maximumMessageBytes: Int = defaultMaximumMessageBytes
    ) {
        self.allowedTextKeys = allowedTextKeys
        self.allowedQueryParameters = allowedQueryParameters
        self.urlDetail = urlDetail
        self.maximumBodySize = max(0, maximumBodySize)
        self.maximumMessageBytes = max(0, maximumMessageBytes)
    }

    /// The redactor of the spec's reference implementation, with every kind on.
    func makeRedactor() -> SensitiveDataRedactor {
        SensitiveDataRedactor(
            kinds: .all,
            allowedTextKeys: allowedTextKeys,
            allowedQueryParameters: allowedQueryParameters,
            urlDetail: urlDetail == .full ? .full : .hostOnly,
            maximumBodySize: maximumBodySize
        )
    }
}
