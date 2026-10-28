import Foundation
import MobileLogger

/// Events an app might log carelessly, each with something that must not reach a log.
enum SampleEvent: String, CaseIterable, Identifiable {
    case signIn = "Sign in"
    case request = "API request"
    case payment = "Payment"
    case failure = "Upload failure"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .signIn: "person.badge.key"
        case .request: "network"
        case .payment: "creditcard"
        case .failure: "exclamationmark.triangle"
        }
    }

    func log(with log: MobileLogger) {
        switch self {
        case .signIn:
            log.notice("Sign-in submitted password=hunter2", metadata: ["email": "alice@example.com", "attempt": 1])
        case .request:
            let url = URL(string: "https://api.example.com/users/12345678/orders?page=2&session=Qz9Wk7rX")!
            let body = Data(#"{"orders":3,"refresh_token":"8f14e45fceea167a5a36dedd4bea2543"}"#.utf8)
            log.info("Request finished", metadata: [
                "url": .url(url), "status": 200, "duration_ms": 182, "response": .body(body, contentType: "application/json"),
            ])
        case .payment:
            log.info("Payment authorised", metadata: ["note": "paid with 4242 4242 4242 4242", "iban": "DE89 3704 0044 0532 0130 00"])
        case .failure:
            log.error("Upload failed: Bearer abcdefgh12345678 rejected", metadata: ["error": .error(URLError(.timedOut))])
        }
    }
}
