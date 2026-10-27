import Foundation

/// The metadata of one log message: values by key.
///
/// Keys are compared with the secret names of the redaction spec, so `"password"`, `"api_key"`
/// or `"session_id"` hide their value, and so does any key that is not plain ASCII.
public typealias LogMetadata = [String: LogValue]

/// A value in the metadata of a log message.
///
/// Write values as literals (`"home"`, `42`, `0.25`, `true`, arrays and dictionaries); use
/// ``url(_:)`` for a URL and ``body(_:contentType:)`` for an HTTP body so they are read with the
/// right parser:
///
/// ```swift
/// log.info("Request finished", metadata: [
///     "url": .url(request.url!),
///     "status": 200,
///     "duration_ms": 182,
///     "response": .body(data, contentType: response.mimeType),
/// ])
/// ```
///
/// Nothing in a value is written as given: ``MobileLogger`` redacts every value before a sink
/// sees it.
public indirect enum LogValue: Sendable, Hashable {
    /// Text, read as free text: a secret name in it hides the rest of the string.
    case string(String)
    /// A whole number.
    case int(Int)
    /// A floating-point number. Infinity and NaN are written as the strings `inf`, `-inf` and
    /// `nan`, since JSON has no numbers for them.
    case double(Double)
    /// A Boolean.
    case bool(Bool)
    /// A URL, written the way the redaction spec writes URLs: without user name, password and
    /// fragment, with identifiers in the path replaced by `:id` and query values hidden unless
    /// their parameter is allowed in ``RedactionPolicy/allowedQueryParameters``.
    case url(URL)
    /// An HTTP body, read with the parser its content type names (JSON, form, multipart or plain
    /// text). Any other body, and one that does not parse completely, is replaced by a note such
    /// as `[body omitted: 512 bytes, application/xml]`.
    case body(Data, contentType: String?)
    /// A list of values.
    case array([LogValue])
    /// Values by key; keys follow the same rules as metadata keys.
    case dictionary([String: LogValue])
    /// No value.
    case null

    /// The type and description of an error, as a dictionary with the keys `kind` and
    /// `description`. The description is free text and is redacted like any other string.
    ///
    /// The type is under `kind`, not `type`: the spec reads the value of a `type` member as the
    /// name of a field, and a Swift type name with punctuation in it would then hide the
    /// description beside it.
    public static func error(_ error: any Error) -> LogValue {
        .dictionary([
            "kind": .string(String(reflecting: type(of: error))),
            "description": .string(String(describing: error))
        ])
    }
}

extension LogValue: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension LogValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension LogValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension LogValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension LogValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: LogValue...) {
        self = .array(elements)
    }
}

extension LogValue: ExpressibleByDictionaryLiteral {
    /// Creates a dictionary value; when a key is repeated, the last value is kept.
    public init(dictionaryLiteral elements: (String, LogValue)...) {
        self = .dictionary(Dictionary(elements, uniquingKeysWith: { _, last in last }))
    }
}

extension LogValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}
