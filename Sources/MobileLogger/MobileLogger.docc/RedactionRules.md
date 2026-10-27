# Redaction rules

What MobileLogger hides, how it reads each kind of input, and what it does not find.

## Overview

MobileLogger does not have redaction rules of its own. It hands every message, metadata
object, URL and body to `SensitiveDataRedactor` from iOSSecurityTools 2.1.2, the reference
implementation ("S") of the shared redaction spec, REDACTION-SPEC 2.1-r2, with every kind of
detector on. The spec's required test set (§8) and its corpus of 7,866 adversarial inputs run
through MobileLogger's own entry points in the package's tests, and the output must equal the
reference redactor's for each one.

The guiding rule: **what the redactor does not fully understand is hidden, never shown.**
Hiding too much is by design.

### Messages: one cut point

A message is free text, read once from left to right. At the first trigger, everything from
there to the end of the message, later lines included, becomes `[redacted]`. Triggers include:

- a key that is not allowed: `user=bob` writes `user=[redacted]`, `Error: refused` writes
  `Error: [redacted]`. The keys `status`, `method`, `path`, `duration_ms` and `count` are allowed,
  and ``RedactionPolicy/allowedTextKeys`` adds more;
- a secret name, also without a separator and with one look-alike letter: `PIN 1234`,
  `pɑssword hunter2`;
- a character outside the safe alphabet (letters, marks and digits of any script and printable
  ASCII), such as an emoji, `→`, a non-breaking space or a zero-width character;
- any escape (`%3D`, `&colon;`, a backslash before anything but white space), a markup tag
  (`<user>`), a quote that does not close on its line, a word longer than 256 characters;
- a URL that is not clean: one with a query, a port, user info or a fragment. A clean URL is
  shown with identifiers in its path replaced by `:id`.

A message longer than ``RedactionPolicy/maximumMessageBytes`` (64 KiB by default) is replaced
by `[redacted]` without being read.

### Metadata: one JSON object

The metadata is encoded as one JSON object with sorted keys and redacted as a JSON body:

- **Keys.** Only a plain-ASCII key (`A–Z a–z 0–9 _ - . space`, at most 256 characters) is
  compared with the secret names; `PASS-WORD`, `pass_word` and `pass.word` read as `password`.
  Any other key, such as `pаssword` with a Cyrillic `а`, `şifre` or `user[id]`, hides its
  value. A hidden value is hidden whole: a string, a number, an array or a dictionary.
- **Held names.** A member that holds the name of a field (`name`, `key`, `field`, `label`,
  `type`, `header`, `param`, `path`, `id`) and names a secret hides the other members of its
  dictionary: `["label": "Password", "value": "hunter2"]` hides `value`. The name and the value
  may be URLs or bodies too: a `label` body that reads `password` hides a `value` URL.
- **Strings** are free text, each on its own, read like a message.
- **Numbers** of 13 digits or more are written as strings so the card number detector reads
  them; the spec's JSON reading does not look into numbers. NaN and infinity become `nan`,
  `inf` and `-inf`.
- Metadata nested more than 64 levels, larger than ``RedactionPolicy/maximumBodySize``
  (256 KiB) as JSON, or holding more than that of URLs and bodies together, is omitted whole
  and ``LogRecord/omittedMetadata`` says why. Each URL and body counts with its full size,
  charged before it is read, so many bodies under the limit are omitted together instead of
  being read one after another. A single URL or body past the limit is not read: a URL is
  hidden, a body is written as its note.

### URLs and bodies

A ``LogValue/url(_:)`` is written without user name, password and fragment; path segments that
look like identifiers or follow a secret name become `:id`; query values are hidden unless
their parameter is in ``RedactionPolicy/allowedQueryParameters``. A host that names a secret
hides everything after the scheme. A path with dot segments, `;` or escaped separators is cut
to scheme and host, because servers resolve such paths differently.

A ``LogValue/body(_:contentType:)`` is read by its content type: JSON, form, multipart or plain
text. A body of another type, one that does not parse completely and one that a common server
parser could split differently is replaced by a note such as
`[body omitted: 512 bytes, application/xml]`.

### Value detectors

On every path (messages, keys, values, URLs and bodies):

| Detector        | Finds                                                            | Written as          |
| --------------- | ---------------------------------------------------------------- | ------------------- |
| Card numbers    | 13–19 digits passing the Luhn check, grouped or not              | `•••• 4242`         |
| IBANs           | country code, check digits, mod-97 valid                         | `•••• 3000`         |
| Email addresses | any script, IDN domains                                          | `a•••@example.com`  |
| JSON Web Tokens | `eyJ…` with two to five segments                                 | `[redacted]`        |
| Bearer tokens   | the token after `Bearer`                                         | `Bearer [redacted]` |
| Long tokens     | 32+ hex digits, or 32+ base64 characters with letters and digits | `[redacted]`        |
| URL passwords   | `user:password@host` in text                                     | `[redacted]`        |

Full-width digits, zero-width characters and Unicode spaces do not hide a finding.

### What is not found

The spec lists what it does not find; MobileLogger inherits that list. Among them: a secret
with no label (`hunter2 is my password`, `--user SECRET`), a name spelled with several
look-alike letters or digits (`p@ssword`), a secret word in another language (`пароль`), a card
number split by `.` or a line break, a short ordinary-looking path segment (`/reset/abc123`),
and phone numbers, for which the spec defines no detector. The policy cannot switch the
secret-name rule off: without it, `password=hunter2` would be written as it is.

The subsystem and the category are not redacted either. They are names chosen in code, not
data, and every sink and export writes them as given; so is the label of a swift-log `Logger`,
which `RedactingLogHandler` makes the category. Keep them fixed names such as `Checkout` or
`com.example.sync`, and put values in the message or the metadata.
