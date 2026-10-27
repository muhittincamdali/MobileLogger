import Foundation
import iOSSecurityTools

/// Turns a message and its metadata into redacted text and values with the spec's redactor.
///
/// The metadata is read as one JSON object, the structured input of the redaction spec: keys are
/// judged by the secret-name rule, a member that names a secret hides the other members of its
/// object, and strings are free text. URLs and bodies are read by their own parsers: in the JSON
/// they stand as a marker word, and only where that word comes back unchanged (its key and its
/// neighbours hide nothing) is the redacted URL or body put in its place.
struct RecordRedactor: Sendable {
    /// Stands for a URL or body in the JSON that is redacted. Plain lowercase ASCII that names no
    /// secret, so free text keeps it unless its key or a neighbour hides it.
    static let marker = "mobileloggerref"

    /// JSON may be open this many levels in all (REDACTION-SPEC L3); the metadata object is one.
    static let maximumDepth = 64

    /// Integers with at least this magnitude are written as strings, so the card number detector
    /// reads them: the spec's JSON reading does not look into numbers (§9.3).
    static let smallestDigitString: UInt = 1_000_000_000_000

    let redactor: SensitiveDataRedactor
    let maximumMessageBytes: Int
    let maximumBodySize: Int

    init(policy: RedactionPolicy) {
        redactor = policy.makeRedactor()
        maximumMessageBytes = policy.maximumMessageBytes
        maximumBodySize = policy.maximumBodySize
    }

    /// The message as free text; a message longer than the limit is hidden whole, unread.
    func message(_ text: String) -> String {
        guard text.utf8.count <= maximumMessageBytes else { return SensitiveDataRedactor.replacement }
        return redactor.redact(text)
    }

    /// The metadata as redacted values, or a note that says why none of it is kept.
    func metadata(_ metadata: LogMetadata) -> (values: [String: RedactedValue], omitted: String?) {
        guard !metadata.isEmpty else { return ([:], nil) }
        var budget = maximumBodySize
        let encoded: Any
        do {
            encoded = try Self.jsonObject(.dictionary(metadata), depth: 1, budget: &budget)
        } catch let failure {
            return ([:], failure.note)
        }
        guard let data = try? JSONSerialization.data(withJSONObject: encoded, options: [.sortedKeys, .withoutEscapingSlashes]) else {
            return ([:], MetadataFailure.unreadable.note)
        }
        let output = redactor.redact(body: data, contentType: "application/json")
        guard output.hasPrefix("{"),
              let parsed = try? JSONSerialization.jsonObject(with: Data(output.utf8)) as? [String: Any]
        else {
            // The redactor omitted the JSON (too large, too deep): its note says so.
            return ([:], output.hasPrefix("{") ? MetadataFailure.unreadable.note : output)
        }
        var values: [String: RedactedValue] = [:]
        for (key, value) in parsed {
            values[key] = restore(value, input: metadata[key])
        }
        return (values, nil)
    }

    /// The text written for a URL: as `redact(url:)` writes it, or hidden whole when the URL is
    /// longer than the body limit.
    func url(_ url: URL) -> String {
        guard url.absoluteString.utf8.count <= maximumBodySize else { return SensitiveDataRedactor.replacement }
        return redactor.redact(url: url)
    }

    // MARK: - Encoding

    enum MetadataFailure: Error {
        case tooDeep
        case tooLarge
        case unreadable

        var note: String {
            switch self {
            case .tooDeep: "[metadata omitted: nested more than \(RecordRedactor.maximumDepth) levels]"
            case .tooLarge: "[metadata omitted: larger than the body limit]"
            case .unreadable: "[metadata omitted: unreadable]"
            }
        }
    }

    /// The Foundation object `JSONSerialization` writes for a value. `budget` counts down the
    /// bytes of text written, so a huge string fails before it is copied into JSON.
    static func jsonObject(_ value: LogValue, depth: Int, budget: inout Int) throws(MetadataFailure) -> Any {
        func spend(_ bytes: Int) throws(MetadataFailure) {
            budget -= bytes
            if budget < 0 { throw .tooLarge }
        }
        switch value {
        case .string(let text):
            try spend(text.utf8.count + 2)
            return text
        case .int(let number):
            try spend(20)
            return number.magnitude >= smallestDigitString ? String(number) : NSNumber(value: number)
        case .double(let number):
            try spend(24)
            return jsonNumber(number)
        case .bool(let flag):
            try spend(5)
            return NSNumber(value: flag)
        case .url, .body:
            try spend(marker.utf8.count + 2)
            return marker
        case .null:
            try spend(4)
            return NSNull()
        case .array(let elements):
            guard depth <= maximumDepth else { throw .tooDeep }
            try spend(2)
            var array: [Any] = []
            array.reserveCapacity(elements.count)
            for element in elements {
                try spend(1)
                array.append(try jsonObject(element, depth: depth + 1, budget: &budget))
            }
            return array
        case .dictionary(let members):
            guard depth <= maximumDepth else { throw .tooDeep }
            try spend(2)
            var object: [String: Any] = [:]
            for (key, member) in members {
                try spend(key.utf8.count + 4)
                object[key] = try jsonObject(member, depth: depth + 1, budget: &budget)
            }
            return object
        }
    }

    /// A finite number below 10^12 as a JSON number; anything else as a string: `nan`, `inf`,
    /// `-inf`, or the number's digits, so detectors read a card number written as a `Double`.
    static func jsonNumber(_ number: Double) -> Any {
        if number.isNaN { return "nan" }
        if number.isInfinite { return number > 0 ? "inf" : "-inf" }
        guard number.magnitude >= Double(smallestDigitString) else { return NSNumber(value: number) }
        return number.rounded() == number ? String(format: "%.0f", number) : String(describing: number)
    }

    // MARK: - Decoding

    /// The redacted value for one parsed JSON value, with the URL or body that `input` holds in
    /// place of an unchanged marker. `input` is nil where the output no longer lines up with it.
    func restore(_ value: Any, input: LogValue?) -> RedactedValue {
        switch value {
        case let text as String:
            guard text == Self.marker else { return .string(text) }
            switch input {
            case .url(let url): return .string(self.url(url))
            case .body(let data, let contentType): return .string(redactor.redact(body: data, contentType: contentType))
            default: return .string(SensitiveDataRedactor.replacement)
            }
        case let number as NSNumber:
            return Self.restore(number)
        case let array as [Any]:
            var elements: [LogValue]? = nil
            if case .array(let given) = input, given.count == array.count { elements = given }
            return .array(array.enumerated().map { restore($0.element, input: elements?[$0.offset]) })
        case let object as [String: Any]:
            var members: [String: LogValue]? = nil
            if case .dictionary(let given) = input { members = given }
            var restored: [String: RedactedValue] = [:]
            for (key, member) in object {
                restored[key] = restore(member, input: members?[key])
            }
            return .object(restored)
        default:
            return .null
        }
    }

    static func restore(_ number: NSNumber) -> RedactedValue {
        if CFGetTypeID(number) == CFBooleanGetTypeID() { return .bool(number.boolValue) }
        if CFNumberIsFloatType(number) { return .double(number.doubleValue) }
        if let integer = Int(exactly: number.int64Value), NSNumber(value: integer) == number { return .int(integer) }
        // A whole number beyond `Int`: kept as its digits.
        return .string(number.stringValue)
    }
}
