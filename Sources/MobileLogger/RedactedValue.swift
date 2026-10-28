import Foundation

/// A metadata value after redaction: what a sink stores and an export writes.
///
/// It has the shape of a JSON value. A hidden value of any type is the string `[redacted]`, a
/// URL or body is the string the redactor wrote for it, and a number that could hold a card
/// number (13 digits or more) is a string, so the card number detector reads it.
public enum RedactedValue: Sendable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([RedactedValue])
    case object([String: RedactedValue])
    case null

    /// The string, if the value is one.
    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    /// A rough count of the bytes the value takes in an export, for the memory budget of
    /// ``MemoryLogStore``.
    var estimatedSize: Int {
        switch self {
        case .string(let value): value.utf8.count + 2
        case .int, .double: 8
        case .bool: 5
        case .null: 4
        case .array(let values): values.reduce(2) { $0 + $1.estimatedSize + 1 }
        case .object(let members): members.reduce(2) { $0 + $1.key.utf8.count + 4 + $1.value.estimatedSize }
        }
    }
}

extension RedactedValue: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([RedactedValue].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: RedactedValue].self))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let values): try container.encode(values)
        case .object(let members): try container.encode(members)
        case .null: try container.encodeNil()
        }
    }
}
