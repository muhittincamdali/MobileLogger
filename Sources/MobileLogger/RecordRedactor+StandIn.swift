import Foundation
import iOSSecurityTools

/// The stand-ins that both JSON passes over metadata put in place of URLs and bodies.
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
///
/// A parser may also rewrite a name: the relative URL `password` is written as `<unparsed URL>`
/// and a body `%card` as `[redacted]`, and neither text names a secret. The URL or body as it
/// was given is read the same way, and where it names a secret that its text does not, both
/// passes put the naming word in its place, so its neighbours are hidden as they are beside the
/// same name given as a string.
extension RecordRedactor {
    /// Stands for a URL or body that names a secret to its neighbours: free text keeps it, and it
    /// names a secret as a member of any key and in any array.
    static let namingWord = "password"

    /// The JSON of each pass: for the first, the written text of each URL and body, or
    /// ``namingWord`` where only the URL or body as given names a secret to its neighbours; for
    /// the second, ``namingWord`` where the text or the URL or body as given names one, and
    /// ``marker`` elsewhere.
    func standIns(_ json: Any, shape: Shape) -> (written: Any, marked: Any) {
        switch shape {
        case .plain: return (json, json)
        case .redacted: return (json, Self.marker)
        case .array(let shapes):
            guard let array = json as? [Any] else { return (json, json) }
            var written: [Any] = []
            var marked: [Any] = []
            for (index, (element, shape)) in zip(array, shapes).enumerated() {
                let pass: (written: Any, marked: Any) = if case .redacted(let text, let given) = shape, array.count > 1 {
                    standIn(element, text: text, given: given) { namesSecret($0, at: index, of: array.count) }
                } else {
                    standIns(element, shape: shape)
                }
                written.append(pass.written)
                marked.append(pass.marked)
            }
            return (written, marked)
        case .object(let shapes):
            guard let object = json as? [String: Any] else { return (json, json) }
            var written: [String: Any] = [:]
            var marked: [String: Any] = [:]
            for (key, member) in object {
                let pass: (written: Any, marked: Any) = if case .redacted(let text, let given) = shapes[key], object.count > 1 {
                    standIn(member, text: text, given: given) { namesSecret($0, key: key) }
                } else if let shape = shapes[key] {
                    standIns(member, shape: shape)
                } else {
                    (member, member)
                }
                written[key] = pass.written
                marked[key] = pass.marked
            }
            return (written, marked)
        }
    }

    /// The stand-ins of one URL or body that has neighbours, written as `text` and given as the
    /// texts in `given`. `names` tells whether a text in its place names a secret to them.
    private func standIn(_ json: Any, text: String, given: [String], names: (String) -> Bool) -> (written: Any, marked: Any) {
        if names(text) { return (json, Self.namingWord) }
        guard given.contains(where: { $0 != text && names($0) }) else { return (json, Self.marker) }
        return (Self.namingWord, Self.namingWord)
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
