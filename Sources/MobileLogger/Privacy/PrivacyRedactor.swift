import Foundation

// MARK: - PrivacyRedactor

/// Detects and masks personally identifiable information (PII) in log messages.
///
/// Supports redaction of email addresses, phone numbers, and IPv4 addresses
/// out of the box. You can add custom patterns for additional data types.
///
/// ```swift
/// let redactor = PrivacyRedactor()
/// let safe = redactor.redact("Email: john@example.com, IP: 192.168.1.1")
/// // "Email: [REDACTED_EMAIL], IP: [REDACTED_IP]"
/// ```
public final class PrivacyRedactor: @unchecked Sendable {

    // MARK: - Types

    /// A named redaction rule consisting of a regex pattern and replacement.
    public struct Rule: Sendable {
        /// Human-readable name for the rule.
        public let name: String
        /// The compiled regular expression.
        public let regex: NSRegularExpression
        /// The replacement string.
        public let replacement: String

        /// Creates a new redaction rule.
        ///
        /// - Parameters:
        ///   - name: Rule name.
        ///   - pattern: Regex pattern string.
        ///   - replacement: Replacement text.
        public init(name: String, pattern: String, replacement: String) {
            // swiftlint:disable:next force_try
            self.regex = try! NSRegularExpression(pattern: pattern, options: [])
            self.name = name
            self.replacement = replacement
        }
    }

    // MARK: - Properties

    /// Active redaction rules applied in order.
    public private(set) var rules: [Rule]

    /// Whether redaction is enabled. Defaults to `true`.
    public var isEnabled: Bool = true

    // MARK: - Default Patterns

    /// Regex pattern matching most email addresses.
    private static let emailPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    /// Regex pattern matching common phone number formats.
    private static let phonePattern = "(?:\\+?\\d{1,3}[-.\\s]?)?(?:\\(?\\d{2,4}\\)?[-.\\s]?)?\\d{3,4}[-.\\s]?\\d{3,4}"

    /// Regex pattern matching IPv4 addresses.
    private static let ipv4Pattern = "\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b"

    // MARK: - Initialization

    /// Creates a new privacy redactor with the default rule set.
    ///
    /// - Parameter includeDefaults: Whether to include built-in rules (default `true`).
    public init(includeDefaults: Bool = true) {
        if includeDefaults {
            self.rules = [
                Rule(name: "email", pattern: Self.emailPattern, replacement: "[REDACTED_EMAIL]"),
                Rule(name: "ipv4", pattern: Self.ipv4Pattern, replacement: "[REDACTED_IP]"),
                Rule(name: "phone", pattern: Self.phonePattern, replacement: "[REDACTED_PHONE]")
            ]
        } else {
            self.rules = []
        }
    }

    // MARK: - Public Methods

    /// Adds a custom redaction rule.
    ///
    /// - Parameter rule: The rule to add.
    public func addRule(_ rule: Rule) {
        rules.append(rule)
    }

    /// Applies all redaction rules to the input string.
    ///
    /// - Parameter input: The raw string potentially containing PII.
    /// - Returns: The redacted string.
    public func redact(_ input: String) -> String {
        guard isEnabled else { return input }

        var result = input
        let range = NSRange(result.startIndex..., in: result)

        for rule in rules {
            result = rule.regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: rule.replacement
            )
        }

        return result
    }
}
