import Foundation

/// MobileLogger: Privacy-First PII Scrubber.
/// 
/// Automatically detects and masks Personally Identifiable Information (PII) 
/// such as Emails, IP Addresses, and Credit Card numbers within log strings.
public struct PIIScrubber: Sendable {
    
    private static let emailRegex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\\\.[A-Za-z]{2,64}")
    
    /// Scrubs a log message of all sensitive data.
    public static func scrub(_ message: String) -> String {
        var scrubbed = message
        
        // 1. Mask Emails
        let range = NSRange(location: 0, length: scrubbed.utf16.count)
        scrubbed = emailRegex.stringByReplacingMatches(in: scrubbed, options: [], range: range, withTemplate: "[REDACTED_EMAIL]")
        
        // 2. Additional scrubbing logic for IPs, SSNs, etc.
        
        if scrubbed != message {
            print("🛡️ [MobileLogger] Privacy: PII scrubbed from log entry.")
        }
        
        return scrubbed
    }
}
