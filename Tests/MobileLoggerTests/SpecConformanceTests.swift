import Foundation
import Testing
@testable import MobileLogger

/// The required test set of the shared redaction spec (REDACTION-SPEC 2.1-r2, §8), run through
/// this package's own entry points: messages are free text (§8.3, §8.5), `LogValue.body` is the
/// body input (§8.1), `LogValue.url` the URL input (§8.4) and the metadata object itself the
/// structured input (§8.1 #1–#10, §8.2, §8.3 #34). The expected outputs are those of the
/// reference implementation ("S"), whose redactor the logger uses; `[R]` is `[redacted]`.
@Suite("Redaction spec §8 through MobileLogger")
struct SpecConformanceTests {
    // MARK: §8.1 keys and bodies

    @Test("§8.1 #1–#10: JSON bodies keep names and hide values by name and by held name", arguments: [
        (#"{"user":"bob","password":"hunter2"}"#, #"{"user":"bob","password":"[redacted]"}"#),
        (#"{"password":"hunter2","id":"7"}"#, #"{"password":"[redacted]","id":"7"}"#),
        (#"{"PASS-WORD":"a","pass.word":"b","created_at":"c"}"#, #"{"PASS-WORD":"[redacted]","pass.word":"[redacted]","created_at":"c"}"#),
        (
            #"{"p\#u{0430}ssword":"x","şifre":"y","user[id]":"z","ok":"1"}"#,
            #"{"p\#u{0430}ssword":"[redacted]","şifre":"[redacted]","user[id]":"[redacted]","ok":"1"}"#
        ),
        (#"{"token":"a","token":"b"}"#, #"{"token":"[redacted]","token":"[redacted]"}"#),
        (#"{"password":{"a":[1,2]},"x":1}"#, #"{"password":"[redacted]","x":1}"#),
        (#"{"note":"password=hunter2","ok":"fine"}"#, #"{"note":"password=[redacted]","ok":"fine"}"#),
        (
            #"[{"op":"replace","path":"/user/password","value":"hunter2"},{"op":"replace","path":"/status","value":"active"}]"#,
            #"[{"op":"replace","path":"/user/password","value":"[redacted]"},{"op":"replace","path":"/status","value":"active"}]"#
        ),
        (
            #"[{"label":"Şifre","value":"hunter2"},{"label":"ⓟⓘⓝ","value":"1234"},{"label":"status","value":"ok"}]"#,
            #"[{"label":"Şifre","value":"[redacted]"},{"label":"[redacted]","value":"[redacted]"},{"label":"status","value":"ok"}]"#
        ),
        (#"[["Authorization","Bearer abc"],["Accept","x"]]"#, #"[["Authorization","[redacted]"],["Accept","x"]]"#),
    ])
    func jsonBodies(input: String, expected: String) {
        #expect(redactedBody(input, contentType: "application/json") == expected)
    }

    @Test("§8.1 #1, #3, #4, #6, #7: metadata keys follow the key rule (K1–K8)")
    func metadataKeys() {
        let values = record(metadata: [
            "user": "bob", "password": "hunter2", "PASS-WORD": "a", "pass.word": "b", "created_at": "c",
            "p\u{0430}ssword": "x", "şifre": "y", "user[id]": "z", "ok": "1",
            "secret": ["a": [1, 2]], "note": "password=hunter2",
        ]).metadata
        #expect(values["user"] == .string("bob"))
        #expect(values["created_at"] == .string("c"))
        #expect(values["ok"] == .string("1"))
        for key in ["password", "PASS-WORD", "pass.word", "p\u{0430}ssword", "şifre", "user[id]", "secret"] {
            #expect(values[key] == .string(replacement), "\(key)")
        }
        #expect(values["note"] == .string("password=[redacted]"))
    }

    @Test("§8.1 #8–#10: held names in metadata hide the values beside them (K10)")
    func metadataHeldNames() {
        let patch = record(metadata: [
            "changes": [
                ["op": "replace", "path": "/user/password", "value": "hunter2"],
                ["op": "replace", "path": "/status", "value": "active"],
            ],
        ]).metadata["changes"]
        #expect(patch == .array([
            .object(["op": .string("replace"), "path": .string("/user/password"), "value": .string(replacement)]),
            .object(["op": .string("replace"), "path": .string("/status"), "value": .string("active")]),
        ]))
        let labels = record(metadata: ["fields": [["label": "Şifre", "value": "hunter2"], ["label": "status", "value": "ok"]]]).metadata["fields"]
        #expect(labels == .array([
            .object(["label": .string("Şifre"), "value": .string(replacement)]),
            .object(["label": .string("status"), "value": .string("ok")]),
        ]))
        let headers = record(metadata: ["headers": [["Authorization", "Bearer abc"], ["Accept", "x"]]]).metadata["headers"]
        #expect(headers == .array([.array([.string("Authorization"), .string(replacement)]), .array([.string("Accept"), .string("x")])]))
    }

    @Test("§8.1 #11–#13: unparsable, other-type and too-deep bodies are omitted")
    func omittedBodies() {
        for text in [#"{"a":1,}"#, #"{"a":NaN}"#, #"{"a":1}{"b":2}"#] {
            #expect(redactedBody(text, contentType: "application/json") == "[body omitted: \(text.utf8.count) bytes, application/json]")
        }
        #expect(redactedBody("<password>hunter2</password>", contentType: "application/xml") == "[body omitted: 28 bytes, application/xml]")
        let deep = String(repeating: "[", count: 65) + String(repeating: "]", count: 65)
        #expect(redactedBody(deep, contentType: "application/json") == "[body omitted: 130 bytes, application/json]")
        let deepInString = #"{"note":""# + String(repeating: "[", count: 64) + String(repeating: "]", count: 64) + #" ok"}"#
        #expect(redactedBody(deepInString, contentType: "application/json") == #"{"note":"[redacted]"}"#)
    }

    @Test("§8.1 #13 (L3): JSON in a metadata string counts the metadata object's level")
    func deepJSONInMetadataString() {
        let deep = String(repeating: "[", count: 64) + String(repeating: "]", count: 64) + " ok"
        #expect(redactedValue(.string(deep), key: "note") == .string(replacement))
        let shallow = String(repeating: "[", count: 62) + String(repeating: "]", count: 62) + " ok"
        #expect(redactedValue(.string(shallow), key: "note") == .string(shallow))
    }

    @Test("§8.1 #14–#16: strict forms are read, others omitted")
    func forms() {
        let type = "application/x-www-form-urlencoded"
        #expect(
            redactedBody("p%D0%B0ssword=a&pass.word=b&user%5Bname%5D=c&user.name=bob", contentType: type)
                == "p%D0%B0ssword=[redacted]&pass.word=[redacted]&user%5Bname%5D=[redacted]&user.name=bob")
        for text in ["a=1;b=2", "a=100%&b=2", "a.b=1&a_b=2"] {
            #expect(redactedBody(text, contentType: type) == "[body omitted: \(text.utf8.count) bytes, \(type)]", "\(text)")
        }
        #expect(redactedBody("label=Password&value=hunter2&x=1", contentType: type) == "label=Password&value=[redacted]&x=[redacted]")
    }

    @Test("§8.1 #17–#18: multipart part headers are keys; a delimiter after a bare LF omits the body")
    func multipart() throws {
        let type = "multipart/form-data; boundary=B0und"
        let part = "--B0und\r\nContent-Disposition: form-data; name=\"a\"\r\nX-4111111111111111: 1\r\nContent-Length: 1\r\n\r\nx\r\n--B0und--"
        let output = try #require(redactedBody(part, contentType: type))
        #expect(output.contains("[redacted]: [redacted]"))
        #expect(output.contains("Content-Length: 1"))
        #expect(!output.contains("4111"))
        let bareLineFeed = "--B0und\r\nContent-Disposition: form-data; name=\"note\"\r\n\r\nhi\n--B0und\r\n"
            + "Content-Disposition: form-data; name=\"pin\"\r\n\r\n4831\r\n--B0und--"
        #expect(redactedBody(bareLineFeed, contentType: type) == "[body omitted: \(bareLineFeed.utf8.count) bytes, multipart/form-data]")
    }

    @Test("§8.1 #17b: kept part header values are written by their shape", arguments: [
        ("Content-Length: pin-4831", "Content-Length: [redacted]"),
        ("Content-Length: 12 hunter2", "Content-Length: [redacted]"),
        ("Content-Transfer-Encoding: hunter2", "Content-Transfer-Encoding: [redacted]"),
        ("Content-Transfer-Encoding: BASE64", "Content-Transfer-Encoding: base64"),
    ])
    func partHeaderValues(header: String, expected: String) throws {
        let part = "--B0und\r\nContent-Disposition: form-data; name=\"a\"\r\n\(header)\r\n\r\nx\r\n--B0und--"
        let output = try #require(redactedBody(part, contentType: "multipart/form-data; boundary=B0und"))
        #expect(output.components(separatedBy: "\r\n").dropFirst(2).first == expected, "\(output.debugDescription)")
    }

    @Test("§8.1 #17c, P3: a message past the reading limit is hidden whole, unread", arguments: [1, 100, 4_101])
    func messageOverLimit(extra: Int) {
        let limit = 4_096
        let policy = RedactionPolicy(maximumMessageBytes: limit)
        let text = String(repeating: "a", count: limit - 20) + " password=hunter2 " + String(repeating: "b", count: extra + 2)
        #expect(text.utf8.count > limit)
        #expect(redactedMessage(text, policy: policy) == replacement)
    }

    @Test("§8.1 #19: a content type with a second type is unreadable")
    func contentType() {
        #expect(redactedBody(#"{"a":1}"#, contentType: "application/json, text/plain") == "[body omitted: 7 bytes, unreadable content type]")
    }

    // MARK: §8.2 control characters and held names

    @Test("§8.2 #20–#24: control characters in held names hide the values beside them")
    func controlCharacters() {
        #expect(record(metadata: ["name": "Hello\nWorld", "value": "x"]).metadata["value"] == .string(replacement))
        #expect(record(metadata: ["note": "pass\nword", "id": "7"]).metadata["id"] == .string(replacement))
        #expect(record(metadata: ["title": "\n", "data": "x"]).metadata["data"] == .string(replacement))
        let tab = record(metadata: ["ParameterKey": "\t", "ParameterValue": "x"]).metadata
        #expect(tab == ["ParameterKey": .string(replacement), "ParameterValue": .string(replacement)])
        #expect(record(metadata: ["ParameterKey": "DbPassword\n", "ParameterValue": "x"]).metadata["ParameterValue"] == .string(replacement))
        #expect(record(metadata: ["OptionName": "pa\nssword", "Value": "x"]).metadata["Value"] == .string(replacement))
        let message = record(metadata: ["message": "Hello\nWorld", "id": "7"]).metadata
        #expect(message == ["message": .string("Hello\nWorld"), "id": .string("7")])
        #expect(
            redactedBody("ParameterKey=%0A&ParameterValue=x", contentType: "application/x-www-form-urlencoded")
                == "ParameterKey=[redacted]&ParameterValue=[redacted]")
    }

    // MARK: §8.3 detectors

    @Test("§8.3 #25–#36: detectors in messages", arguments: [
        ("paid 4111 1111 1111 1111 ok", "paid •••• 1111 ok"),
        ("ok 4111-1111-1111-1111 ok", "ok •••• 1111 ok"),
        ("٤٢٤٢ ٤٢٤٢ ٤٢٤٢ ٤٢٤٢", "•••• 4242"),
        ("ref DE89 3704 0044 0532 0130 00 ok", "ref •••• 3000 ok"),
        ("de89370400440532013000 lowercase", "de89370400440532013000 lowercase"),
        ("mail alice@example.com ok", "mail a•••@example.com ok"),
        ("contact alice%40example.com", "contact [redacted]"),
        ("tok eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U ok", "tok [redacted] ok"),
        ("hdr Bearer abcdefgh12345678 ok", "hdr Bearer [redacted] ok"),
        ("hex 0123456789abcdef0123456789abcdef ok", "hex [redacted] ok"),
        ("uuid 123e4567-e89b-12d3-a456-426614174000 ok", "uuid 123e4567-e89b-12d3-a456-426614174000 ok"),
        ("git clone https://bob:hunter2@github.com/x/y.git", "git clone [redacted]"),
        ("redis://:hunter2@host", "[redacted]"),
        ("paid with 4111 1111 1111\u{2028}1111", "paid with [redacted]"),
        ("paid with 4111 1111 1111\u{000B}1111", "paid with [redacted]"),
        ("paid 4111\u{000C}1111\u{0085}1111\u{2029}1111", "paid [redacted]"),
        ("mail ali\u{2028}ce@example.com ok", "mail [redacted]"),
        ("4111 1111 1111\n1111", "4111 1111 1111\n1111"),
    ])
    func detectors(input: String, expected: String) {
        #expect(redactedMessage(input) == expected)
    }

    @Test("§8.3 #34, P4: detectors run on metadata keys too")
    func detectorsInKeys() {
        let values = record(metadata: ["4111111111111111": 1, "alice@example.com": 2]).metadata
        #expect(values == ["•••• 1111": .int(1), "a•••@example.com": .string(replacement)])
    }

    @Test("§8.3 #37 (stricter than S): numbers that could hold a card number are read by the detectors")
    func cardNumbersAsNumbers() {
        #expect(redactedValue(.int(4_111_111_111_111_111), key: "amount") == .string("•••• 1111"))
        #expect(redactedValue(.int(-4_111_111_111_111_111), key: "amount") == .string("-•••• 1111"))
        #expect(redactedValue(.double(4_111_111_111_111_111), key: "amount") == .string("•••• 1111"))
        #expect(redactedValue(.double(4.111111111111111e15), key: "amount") == .string("•••• 1111"))
        #expect(redactedValue(.double(1e40), key: "amount") == .string(replacement))
        #expect(redactedValue(.int(999_999_999_999), key: "amount") == .int(999_999_999_999))
    }

    // MARK: §8.4 URLs

    @Test("§8.4 #38–#47: URLs in metadata", arguments: [
        ("https://bob:pw@example.com/users/12345678/reset?code=x#y", "https://example.com/users/:id/reset?code=[redacted]"),
        ("https://example.com/v1/cards/4242/pin/4831", "https://example.com/v1/cards/:id/pin/:id"),
        ("https://example.com/pin/./4831", "https://example.com"),
        ("https://example.com/token/x/../4831", "https://example.com"),
        ("https://example.com/a;pin/4831", "https://example.com"),
        ("https://example.com/a%2Fb/c", "https://example.com"),
        ("https://example.com/a%25/x", "https://example.com"),
        ("https://example.com/a%5Cb/x", "https://example.com"),
        ("https://example.com/a%3Bb/x", "https://example.com"),
        ("https://example.com" + String(repeating: "/a", count: 65), "https://example.com"),
        ("https://h.example;password=hunter2/db", "https://[redacted]"),
        ("https://4111111111111111.example.com/a", "https://[redacted]"),
        ("myapp://pin/4831", "myapp://[redacted]"),
        ("myapp://user@pin/Qz743Wk5m", "myapp://[redacted]"),
        ("https://example.com/caf%C3%A9/menu", "https://example.com/caf%C3%A9/:id"),
        ("https://example.com/p%0Ain/4831", "https://example.com/p%0Ain/:id"),
        ("https://example.com/a,b/c", "https://example.com/a,b/:id"),
        ("https://example.com/users/:id/x", "https://example.com/users/:id/x"),
        ("https://example.com/a?page=2&flag", "https://example.com/a?page=[redacted]&[redacted]"),
        ("https://example.com/a?a=1;b=2", "https://example.com/a?[redacted]"),
        ("mailto:ada@example.com", "<unparsed URL>"),
    ])
    func urls(input: String, expected: String) {
        #expect(redactedURL(input) == expected)
    }

    @Test("§5 U9: allowed query parameters keep their values in metadata URLs, never in messages")
    func allowedQueryParameters() {
        let policy = RedactionPolicy(allowedQueryParameters: ["page"])
        #expect(redactedURL("https://example.com/a?page=2&flag", policy: policy) == "https://example.com/a?page=2&[redacted]")
        #expect(redactedMessage("GET https://api.example.com/items?page=2 done", policy: policy) == "GET [redacted]")
    }

    @Test("§5 U11: hostOnly writes scheme and host")
    func hostOnly() {
        let policy = RedactionPolicy(urlDetail: .hostOnly)
        #expect(redactedURL("https://example.com/users/12345678?page=2", policy: policy) == "https://example.com")
    }

    @Test("§8.4 #48, P7: the secret-name rule cannot be switched off, so names always hide values")
    func secretFieldsAlwaysOn() {
        #expect(redactedBody(#"{"password":"hunter2"}"#, contentType: "application/json") == #"{"password":"[redacted]"}"#)
        #expect(redactedMessage("see https://bob:pw@example.com/a#frag ok") == "see [redacted]")
        #expect(redactedURL("https://bob:pw@example.com/a#frag") == "https://example.com/a")
    }

    // MARK: §8.5 the cut point

    @Test("§8.5 #49–#64: messages are cut once, at the first trigger", arguments: [
        ("GET /api/items status=200 method=GET duration_ms=12", "GET /api/items status=200 method=GET duration_ms=12"),
        ("login user=bob status=401 password=hunter2", "login user=[redacted]"),
        ("Error: connection refused\nretrying in 5 s", "Error: [redacted]"),
        ("see https://x.example/a. Next", "see https://x.example/a. Next"),
        ("see https://x.example/a). ok", "see [redacted]"),
        ("see \"https://x.example/a\" ok", "see \"[redacted]"),
        ("GET https://api.example.com/users/12345678 200", "GET https://api.example.com/users/:id 200"),
        ("see https://pin.example/a ok", "see [redacted]"),
        ("https://x.example/to ken hunter2", "https://x.example/to ken [redacted]"),
        (#"cache miss for "session Qz9Wk7rX": refetching"#, "cache miss for [redacted]"),
        (#"{"status":200,"user":"bob"} done"#, #"{"status":200,[redacted]"#),
        ("login t\u{0366}ken hunter2", "login t\u{0366}ken [redacted]"),
        ("p\u{0251}ssword hunter2", "p\u{0251}ssword [redacted]"),
        ("pass word hunter2", "pass [redacted]"),
        ("PIN 1234", "PIN [redacted]"),
        ("bypass ok", "bypass ok"),
        ("1<2 and <3 and a<=b", "1<2 and <3 and a<=[redacted]"),
        ("<_id>7</_id>", "[redacted]"),
        (#"login pa\x{73}sword hunter2"#, "login [redacted]"),
        (#"trailing backslash \"#, #"trailing backslash \"#),
        ("user&colon;hunter2", "[redacted]"),
        ("status=200&count=3", "status=200&count=3"),
        ("user1:2345678 at 12:30", "user1:[redacted]"),
        ("at 2026-10-19T12:30:45.123+03:00 ok", "at 2026-10-19T12:30:45.123+03:00 ok"),
        ("Merhaba dünya 👋 bye", "Merhaba dünya [redacted]"),
        ("a\u{00A0}b", "a[redacted]"),
        ("status=200\u{000B}ok", "status=200[redacted]"),
        ("say (hello", "say ([redacted]"),
        ("field name=\"password\" hunter2", "field name=[redacted]"),
        ("p\u{0430}ssword=hunter2", "p\u{0430}ssword=[redacted]"),
        ("t\u{043E}ken hunter2", "[redacted]"),
    ])
    func cut(input: String, expected: String) {
        #expect(redactedMessage(input) == expected)
    }

    @Test("§8.5 #50: allowedTextKeys reads on after an allowed key")
    func allowedTextKey() {
        let policy = RedactionPolicy(allowedTextKeys: ["user"])
        #expect(redactedMessage("login user=bob status=401 password=hunter2", policy: policy) == "login user=bob status=401 password=[redacted]")
    }
}
