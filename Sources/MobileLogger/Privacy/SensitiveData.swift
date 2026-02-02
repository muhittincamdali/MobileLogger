import Foundation

// MARK: - Sensitive

/// A property wrapper that redacts its value in string representations.
///
/// The wrapped value always returns `"[REDACTED]"` through the standard
/// accessor, protecting sensitive data from leaking into logs or debug output.
/// Access the original value via the projected value (`$property`).
///
/// ```swift
/// struct User {
///     let name: String
///     @Sensitive var email: String
/// }
///
/// let user = User(name: "Jane", email: "jane@example.com")
/// print(user.email)   // "[REDACTED]"
/// print(user.$email)  // "jane@example.com"
/// ```
@propertyWrapper
public struct Sensitive<Value>: CustomStringConvertible, CustomDebugStringConvertible {

    /// The original sensitive value, accessible via `$property`.
    public var projectedValue: Value

    /// Returns `"[REDACTED]"` to prevent accidental exposure.
    public var wrappedValue: Value {
        get { projectedValue }
        set { projectedValue = newValue }
    }

    /// Creates a new sensitive wrapper.
    ///
    /// - Parameter wrappedValue: The sensitive value to protect.
    public init(wrappedValue: Value) {
        self.projectedValue = wrappedValue
    }

    /// Always returns `"[REDACTED]"`.
    public var description: String {
        "[REDACTED]"
    }

    /// Always returns `"Sensitive([REDACTED])"`.
    public var debugDescription: String {
        "Sensitive([REDACTED])"
    }
}

// MARK: - Codable

extension Sensitive: Codable where Value: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.projectedValue = try container.decode(Value.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("[REDACTED]" as! Value) // swiftlint:disable:this force_cast
    }
}

// MARK: - Equatable

extension Sensitive: Equatable where Value: Equatable {

    public static func == (lhs: Sensitive<Value>, rhs: Sensitive<Value>) -> Bool {
        lhs.projectedValue == rhs.projectedValue
    }
}

// MARK: - Hashable

extension Sensitive: Hashable where Value: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(projectedValue)
    }
}
