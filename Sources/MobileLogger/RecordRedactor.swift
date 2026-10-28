import Foundation
import iOSSecurityTools

/// Turns a message and its metadata into redacted text and values with the spec's redactor.
///
/// The metadata is read as one JSON object, the structured input of the redaction spec: keys are
/// judged by the secret-name rule, a member that names a secret hides the other members of its
/// object, and strings are free text. URLs and bodies are read by their own parsers first. When
/// the metadata holds any, the JSON is read twice: once with the text written for each URL and
/// body in its place, so that text names secrets to its neighbours like any other string and
/// every other value is taken from this pass; and once with a stand-in word in its place (see
/// ``standIns(_:shape:)``), a word that names a secret to its neighbours exactly where the text
/// does. Where only the URL or body as given names a secret (its parser rewrote the name), both
/// passes hold that naming word instead. A URL or body is written only where the second pass
/// keeps its word: its key and its neighbours hide nothing. Anywhere else it is hidden.
struct RecordRedactor: Sendable {
    /// Stands for a URL or body that names no secret in the second JSON pass. Plain lowercase
    /// ASCII that names no secret, so free text keeps it unless its key or a neighbour hides it.
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
        var budget = Budget(written: maximumBodySize, read: maximumBodySize)
        let json: Any
        let shape: Shape
        do {
            (json, shape) = try jsonObject(.dictionary(metadata), depth: 1, budget: &budget)
        } catch let failure {
            return ([:], failure.note)
        }
        guard case .object(let shapes) = shape else { return ([:], MetadataFailure.unreadable.note) }
        let texts: [String: Any]
        let marked: [String: Any]
        let passes = shape.holdsURLOrBody ? standIns(json, shape: shape) : (written: json, marked: json)
        switch redactJSON(passes.written) {
        case .failure(let note): return ([:], note.text)
        case .success(let parsed): texts = parsed
        }
        if shape.holdsURLOrBody {
            switch redactJSON(passes.marked) {
            case .failure(let note): return ([:], note.text)
            case .success(let parsed): marked = parsed
            }
        } else {
            marked = texts
        }
        var values: [String: RedactedValue] = [:]
        for (key, value) in texts {
            values[key] = Self.restore(value, marked: marked[key], shape: shapes[key])
        }
        return (values, nil)
    }

    /// A note that says why the metadata is omitted.
    struct OmittedNote: Error {
        let text: String
    }

    /// The JSON object after one pass of the redactor, parsed again.
    func redactJSON(_ json: Any) -> Result<[String: Any], OmittedNote> {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .withoutEscapingSlashes]) else {
            return .failure(OmittedNote(text: MetadataFailure.unreadable.note))
        }
        let output = redactor.redact(body: data, contentType: "application/json")
        guard output.hasPrefix("{"),
              let parsed = try? JSONSerialization.jsonObject(with: Data(output.utf8)) as? [String: Any]
        else {
            // The redactor omitted the JSON (too large, too deep): its note says so.
            return .failure(OmittedNote(text: output.hasPrefix("{") ? MetadataFailure.unreadable.note : output))
        }
        return .success(parsed)
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

    /// Where a value held a URL or body, the text its parser wrote for it and the texts of the URL
    /// or body as it was given (none when it was too large to read), so the output of the JSON
    /// passes can be lined up with the input.
    indirect enum Shape {
        case plain
        case redacted(String, given: [String])
        case array([Shape])
        case object([String: Shape])

        /// Whether a URL or body is anywhere in the value.
        var holdsURLOrBody: Bool {
            switch self {
            case .plain: false
            case .redacted: true
            case .array(let shapes): shapes.contains { $0.holdsURLOrBody }
            case .object(let shapes): shapes.values.contains { $0.holdsURLOrBody }
            }
        }
    }

    /// What the metadata may still take, in bytes: of JSON text written, and of URLs and bodies
    /// read by their parsers. Each starts at the body limit.
    struct Budget {
        var written: Int
        var read: Int
    }

    /// The Foundation object `JSONSerialization` writes for a value, and its shape. `budget`
    /// counts down, so a huge string fails before it is copied into JSON and a URL or body fails
    /// before it is read once the URLs and bodies before it have used up the read budget. A URL or
    /// body goes in as the text its parser wrote for it.
    func jsonObject(_ value: LogValue, depth: Int, budget: inout Budget) throws(MetadataFailure) -> (Any, Shape) {
        func spend(_ bytes: Int) throws(MetadataFailure) {
            budget.written -= bytes
            if budget.written < 0 { throw .tooLarge }
        }
        // A URL or body within the body limit is read whole, so its full size is charged before
        // it is read, however short its text; one past the limit is replaced unread by a note.
        func spendRead(_ size: Int) throws(MetadataFailure) {
            guard size <= maximumBodySize else { return }
            budget.read -= size
            if budget.read < 0 { throw .tooLarge }
        }
        switch value {
        case .string(let text):
            try spend(text.utf8.count + 2)
            return (text, .plain)
        case .int(let number):
            try spend(20)
            return (number.magnitude >= Self.smallestDigitString ? String(number) : NSNumber(value: number), .plain)
        case .double(let number):
            try spend(24)
            return (Self.jsonNumber(number), .plain)
        case .bool(let flag):
            try spend(5)
            return (NSNumber(value: flag), .plain)
        case .url(let url):
            let given = url.absoluteString
            try spendRead(given.utf8.count)
            let text = self.url(url)
            try spend(max(text.utf8.count, Self.marker.utf8.count) + 2)
            return (text, .redacted(text, given: given.utf8.count <= maximumBodySize ? Self.givenTexts(of: given) : []))
        case .body(let data, let contentType):
            try spendRead(data.count)
            let text = redactor.redact(body: data, contentType: contentType)
            try spend(max(text.utf8.count, Self.marker.utf8.count) + 2)
            let given = data.count <= maximumBodySize ? [String(decoding: data, as: UTF8.self)] : []
            return (text, .redacted(text, given: given))
        case .null:
            try spend(4)
            return (NSNull(), .plain)
        case .array(let elements):
            guard depth <= Self.maximumDepth else { throw .tooDeep }
            try spend(2)
            var array: [Any] = []
            var shapes: [Shape] = []
            array.reserveCapacity(elements.count)
            shapes.reserveCapacity(elements.count)
            for element in elements {
                try spend(1)
                let (json, shape) = try jsonObject(element, depth: depth + 1, budget: &budget)
                array.append(json)
                shapes.append(shape)
            }
            return (array, .array(shapes))
        case .dictionary(let members):
            guard depth <= Self.maximumDepth else { throw .tooDeep }
            try spend(2)
            var object: [String: Any] = [:]
            var shapes: [String: Shape] = [:]
            for (key, member) in members {
                try spend(key.utf8.count + 4)
                (object[key], shapes[key]) = try jsonObject(member, depth: depth + 1, budget: &budget)
            }
            return (object, .object(shapes))
        }
    }

    /// The texts a URL was given as: its string and, when that holds percent escapes, the string
    /// they decode to, since `URL(string:)` escapes what it cannot hold (`"\n"` becomes `%0A`).
    static func givenTexts(of url: String) -> [String] {
        guard let decoded = url.removingPercentEncoding, decoded != url else { return [url] }
        return [url, decoded]
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

    /// The redacted value for one parsed JSON value: the first pass's value, except where `shape`
    /// says the input held a URL or body. That one is written as its own parser wrote it when
    /// ``keepsWritten(standIn:)`` says so, and hidden otherwise. `shape` is nil where the
    /// output no longer lines up with the input (a key the redactor rewrote); the first pass's
    /// text is kept there, which is the URL or body text redacted once more as free text, or
    /// ``namingWord`` where only the URL or body as given names a secret.
    static func restore(_ value: Any, marked: Any?, shape: Shape?) -> RedactedValue {
        if case .redacted(let written, _) = shape {
            return .string(keepsWritten(standIn: marked) ? written : SensitiveDataRedactor.replacement)
        }
        switch value {
        case let text as String:
            return .string(text)
        case let number as NSNumber:
            return restore(number)
        case let array as [Any]:
            var shapes: [Shape]? = nil
            var markedElements: [Any]? = nil
            if case .array(let given) = shape, given.count == array.count { shapes = given }
            if let given = marked as? [Any], given.count == array.count { markedElements = given }
            return .array(array.enumerated().map { restore($0.element, marked: markedElements?[$0.offset], shape: shapes?[$0.offset]) })
        case let object as [String: Any]:
            var shapes: [String: Shape]? = nil
            if case .object(let given) = shape { shapes = given }
            let markedMembers = marked as? [String: Any]
            var restored: [String: RedactedValue] = [:]
            for (key, member) in object {
                restored[key] = restore(member, marked: markedMembers?[key], shape: shapes?[key])
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
