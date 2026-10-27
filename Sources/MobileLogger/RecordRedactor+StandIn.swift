import Foundation
import iOSSecurityTools

/// The second JSON pass over metadata that holds URLs and bodies.
///
/// The first pass cannot say whether a URL or body was hidden: its text is read there as free
/// text, and free text may turn it into `[redacted]` as well (`https://example.com/users/:id`
/// does), so a text hidden by its neighbours looks like a text redacted on its own. The second
/// pass puts a word in its place that free text keeps, so a changed word means the URL or body
/// was hidden. That word must name a secret to the neighbours exactly where the text does, or a
/// held name given as a URL or body (`[.body("password"), .body("hunter2")]`) would hide nothing
/// in this pass. Whether a text names a secret depends only on the text, its key and its place
/// in a pair or a longer array (REDACTION-SPEC §2 K10–K13), so it is read from a small JSON
/// object that holds the text and one marker beside it.
extension RecordRedactor {
    /// Stands for a URL or body that names a secret to its neighbours in the second JSON pass:
    /// free text keeps it, and it names a secret as a member of any key and in any array.
    static let namingWord = "password"

    /// The JSON with a stand-in word in place of each URL and body text: ``namingWord`` where the
    /// text names a secret to its neighbours, ``marker`` elsewhere.
    func standIns(_ json: Any, shape: Shape) -> Any {
        switch shape {
        case .plain: return json
        case .redacted: return Self.marker
        case .array(let shapes):
            guard let array = json as? [Any] else { return json }
            return zip(array, shapes).enumerated().map { index, element in
                guard case .redacted(let written) = element.1, array.count > 1 else {
                    return standIns(element.0, shape: element.1)
                }
                return namesSecret(written, at: index, of: array.count) ? Self.namingWord : Self.marker
            }
        case .object(let shapes):
            guard let object = json as? [String: Any] else { return json }
            return object.reduce(into: [String: Any]()) { result, member in
                guard let shape = shapes[member.key] else {
                    result[member.key] = member.value
                    return
                }
                guard case .redacted(let written) = shape, object.count > 1 else {
                    result[member.key] = standIns(member.value, shape: shape)
                    return
                }
                result[member.key] = namesSecret(written, key: member.key) ? Self.namingWord : Self.marker
            }
        }
    }

    /// Whether `text`, as the member `key` of an object, names a secret to the members beside it.
    /// A probe that cannot be read counts as naming one.
    func namesSecret(_ text: String, key: String) -> Bool {
        let neighbour = key == Self.marker ? Self.marker + "x" : Self.marker
        guard case .success(let read) = redactJSON([key: text, neighbour: Self.marker]) else { return true }
        return read[neighbour] as? String != Self.marker
    }

    /// Whether `text`, as element `index` of an array of `count`, names a secret to the elements
    /// beside it. A pair reads its first element as a name; a longer array hides what follows any
    /// element that names a secret, wherever it stands. A probe that cannot be read counts as
    /// naming one.
    func namesSecret(_ text: String, at index: Int, of count: Int) -> Bool {
        let textIndex = count == 2 ? index : 1
        var probe: [Any] = Array(repeating: Self.marker, count: count == 2 ? 2 : 3)
        probe[textIndex] = text
        guard case .success(let parsed) = redactJSON([Self.marker: probe]),
              let read = parsed[Self.marker] as? [Any], read.count == probe.count
        else { return true }
        return read.indices.contains { $0 != textIndex && read[$0] as? String != Self.marker }
    }

    /// Whether a URL or body is written as its parser wrote it: the second pass kept its stand-in
    /// word, so neither its key nor its neighbours hide it. The first pass is no guide here: a
    /// JSON string is read there as free text in its place, which hides texts that are kept on
    /// their own (a body that is JSON nested 64 levels deep, a URL with `:id` in its path).
    static func keepsWritten(standIn: Any?) -> Bool {
        guard let word = standIn as? String else { return false }
        return word == marker || word == namingWord
    }
}
