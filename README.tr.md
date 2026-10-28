<!-- i18n-source: README.md@d9de57463180a0f24deae8e38d6a6e79f81f6be3 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

MobileLogger, iOS, macOS, tvOS, watchOS ve visionOS uygulamaları için yapılandırılmış loglama sunan ve herhangi bir şey yazılmadan önce gizli verileri maskeleyen bir Swift paketidir. Her mesaj ve her metadata değeri, ortak ve yazılı bir maskeleme spesifikasyonunun maskeleyicisinden geçer; böylece unified logging, cihaz üzerindeki depolar ve dışa aktarılan dosya aynı güvenli metni taşır. Logları cihazdan çıkan uygulama ekipleri için tasarlanmıştır: hata raporlarına eklenen, destek ekibi tarafından gönderilen ya da bir sysdiagnose içinden okunan loglar. `os.Logger`'a yazar, logları sabit sınırlar içinde bellekte veya diskte tutar, `ShareLink` için dışa aktarır ve swift-log kullanan paketlerin loglarını da maskeler.

## Öne çıkanlar

- **Her yolda maskeleme** — mesajlar, metadata anahtarları ve değerleri, URL'ler ve HTTP gövdeleri, maskeleme spesifikasyonunun referans uygulaması olan [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) içindeki `SensitiveDataRedactor`'dan geçer: gizli anahtar adları, kart numaraları (Luhn), IBAN'lar (mod-97), e-posta adresleri, JSON Web Token'lar, bearer ve uzun token'lar.
- **Spesifikasyona göre doğrulanır** — spesifikasyonun zorunlu test seti ve 7.866 adversarial girdiden oluşan korpusu, logger'ın kendi giriş noktalarından geçirilir; çıktı her girdi için referans maskeleyicinin çıktısına eşit olmalıdır ve dışa aktarım gizlenen şeyi geri eklememelidir.
- **Fail-closed sınırlar** — aşırı büyük mesajlar, 64 düzeyden fazla iç içe geçmiş, 256 KiB'tan büyük ya da toplamda 256 KiB'tan fazla URL ve gövde içeren metadata ve aşırı uzun URL'ler yarım okunmak yerine tamamen gizlenir; NaN, sonsuz ve `Int.min` değerleri asla trap'e yol açmaz.
- **Sınırlı depolar** — `MemoryLogStore` en yeni kayıtları bir kayıt sayısı ve bayt bütçesi içinde tutar, `FileLogStore` sabit sayıda JSON Lines dosyasını döndürür (rotate eder) ve ikisi de büyümek yerine attıkları kayıtları sayar.
- **Paylaşıma hazır dışa aktarım** — `LogArchive`, seviyeye ve tarihe göre filtrelenmiş JSON Lines veya metin yazar ve `ShareLink` için `Transferable`'a uyar.
- **swift-log köprüsü** — `RedactingLogHandler`, swift-log kullanan her paketin loglarını aynı maskeleyiciden ve depolardan geçirir.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Pencerenin sağ üstündeki arama alanına yapıştırın. **Dependency Rule** ayarını `2.0.0` sürümünden itibaren **Up to Next Major Version** olarak bırakın, ardından **Add Package**'a tıklayın. Açılan pencerede **MobileLogger**'ın yanından uygulama target'ınızı seçin ve **Add Package**'a yeniden tıklayın.

**2. Modülü içe aktarın**

```swift
import MobileLogger
```

Bu satırı, loglama yaptığınız Swift dosyasının en üstüne ekleyin.

**3. Kullanın**

Her özellik için bir logger oluşturun ve verisi metadata içinde olan bir mesaj loglayın:

```swift
import MobileLogger

extension MobileLogger {
    /// One logger per feature; make it once and use it anywhere.
    static let checkout = MobileLogger(category: "Checkout")
}

func quickStart() {
    MobileLogger.checkout.info("Payment sent", metadata: [
        "status": 200,
        "note": "paid with 4242 4242 4242 4242",
        "email": "alice@example.com",
        "password": "hunter2",
    ])
    // Xcode's console and Console.app show:
    // Payment sent {"email":"a•••@example.com","note":"paid with •••• 4242","password":"[redacted]","status":200}
}
```

`quickStart()` fonksiyonunu bir butondan veya `.task` içinden çağırın, uygulamayı çalıştırın ve Xcode konsoluna bakın.

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/MobileLogger.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "MobileLogger", package: "MobileLogger"),
        // Only if the app or its packages log with swift-log:
        .product(name: "MobileLoggerSwiftLog", package: "MobileLogger"),
    ])
]
```

Paket, [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) (maskeleyici) ve [swift-log](https://github.com/apple/swift-log) (yalnızca `MobileLoggerSwiftLog` ürünü kullanır) paketlerine bağlıdır.

## Kullanım

Aşağıdaki örnekler, örnek uygulamanın ve testlerin derlediği [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) ve [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift) dosyalarından kopyalanmıştır; testler yorumlardaki her çıktıyı doğrular.

### Mesaj ve metadata yazma

Mesaj, tek bir kesme noktası olan serbest metindir: izin verilmeyen ilk anahtar ya da ilk gizli anahtar adı, mesajın geri kalanını gizler. Mesajı sabit bir cümle olarak tutun ve değerleri, her anahtarın ayrı ayrı değerlendirildiği metadata içine koyun.

```swift
func messagesAndMetadata(log: MobileLogger) {
    // A message is free text: the first key that is not allowed hides the rest of it.
    log.info("Signed in user=alice")                  // Signed in user=[redacted]
    log.info("GET /orders status=200 duration_ms=41") // kept: status, duration_ms are allowed

    // Metadata keeps values under keys that name no secret.
    log.info("Signed in", metadata: ["user": "alice", "attempt": 2])
    // Signed in {"attempt":2,"user":"alice"}
}
```

### URL'leri ve HTTP gövdelerini loglama

`.url`, kullanıcı adını, parolayı ve fragment'i atar, yoldaki tanımlayıcıları `:id` ile değiştirir ve sorgu değerlerini gizler. `.body`, JSON, form, multipart ve düz metin gövdelerini content type'larına göre okur ve diğer tüm gövdeleri çıktıdan çıkarır.

```swift
func urlsAndBodies(log: MobileLogger) {
    let url = URL(string: "https://bob:pw@api.example.com/users/12345678/orders?page=2#top")!
    let body = Data(#"{"id":7,"access_token":"eyJhbGciOiJIUzI1NiJ9.e30.x","items":3}"#.utf8)
    log.info("Request finished", metadata: [
        "url": .url(url),
        "status": 200,
        "response": .body(body, contentType: "application/json"),
    ])
    // Request finished {"response":"{\"id\":7,\"access_token\":\"[redacted]\",\"items\":3}",
    //   "status":200,"url":"https://api.example.com/users/:id/orders?page=[redacted]"}
}
```

### Logları saklama ve dışa aktarma

```swift
func storesAndExport() async throws -> LogArchive {
    let memory = MemoryLogStore(capacity: 2_000)
    let disk = FileLogStore() // Library/Caches/MobileLogger, 4 files of 1 MiB
    let log = MobileLogger(category: "Sync", sinks: [OSLogSink(), memory, disk])

    log.error("Upload failed", metadata: ["error": .error(URLError(.timedOut)), "attempt": 3])

    // Everything a store holds was redacted when it was logged.
    return try await LogArchive.make(from: disk, format: .text, minimumLevel: .warning)
}
```

Arşivi `ShareLink(item: archive, preview: SharePreview(archive.fileName))` ile paylaşıma verin ya da `archive.write(to:)` ile bir klasöre yazın.

### swift-log'u maskeleyiciden geçirme

```swift
/// Sends the logs of every package that uses swift-log through the redactor. Call it once,
/// early in the app's life: swift-log accepts one bootstrap per process.
func bootstrapSwiftLog(store: MemoryLogStore) {
    let base = MobileLogger(sinks: [OSLogSink(), store])
    LoggingSystem.bootstrap { label in RedactingLogHandler(label: label, logger: base) }

    let logger = Logger(label: "com.example.sync")
    logger.info("Sync finished", metadata: ["token": "abc123", "items": "42"])
    // Sync finished {"items":"42","token":"[redacted]"}
}
```

### İhtiyaç duyduğunuz yerde daha fazlasına izin verme

Varsayılanlar en çok şeyi gizler. Bir `RedactionPolicy` daha fazlasının geçmesine izin verebilir, ancak gizli anahtar adı kuralını veya dedektörleri kapatamaz.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## Başka bir şeye ne zaman başvurmalı

| İhtiyacınız                                      | Kullanın                                                                                                                                         |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Yayımladığınız bir kütüphane için loglama API'si | [swift-log](https://github.com/apple/swift-log); uygulamalar onu `RedactingLogHandler` üzerinden geçirir                                         |
| Konsol arayüzlü bir ağ denetleyicisi             | [Pulse](https://github.com/kean/Pulse); yalnızca adını verdiğiniz header'ları, sorgu öğelerini ve JSON alanlarını maskeler, mesajları maskelemez |
| Unified logging'den hiç çıkmayan loglar          | Her interpolation üzerinde `privacy:` ile `os.Logger`                                                                                            |
| Zaten onu kullanan bir Objective-C kod tabanı    | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                                            |
| Linux sunucularında loglama                      | Bir sunucu handler'ı ile swift-log; MobileLogger OSLog kullanır ve yalnızca Apple platformlarında çalışır                                        |

[Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) makalesi her durumu ve bunların nasıl birleştirileceğini anlatır.

## Demo

| Açık                                                                                           | Koyu                                                                                          |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| ![LogExplorer maskelenmiş kayıtları gösteriyor, açık tema](docs/images/log-explorer-light.png) | ![LogExplorer maskelenmiş kayıtları gösteriyor, koyu tema](docs/images/log-explorer-dark.png) |

[LogExplorer](Examples/LogExplorer) örnek uygulaması, uygulamaların sıklıkla yanlışlıkla yaptığı gibi gizli veri taşıyan dört olayı loglar ve sink'lerinin neler aldığını listeler. Xcode'da `Examples/LogExplorer/LogExplorer.xcodeproj` dosyasını açın, bir iPhone simülatörü veya **My Mac** seçin, **Run**'a basın ve **+** düğmesiyle olay loglayın; paylaş düğmesi bunları dışa aktarır. Ekran görüntüleri uygulamadan [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) ile alınır; ayrıntılar [Examples/README.md](Examples/README.md) dosyasındadır.

## Dokümantasyon

API başvuru belgeleri ve makaleler:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — her public tür; DocC ile oluşturulur ve dokümantasyon workflow'u tarafından yayımlanır.
- Paketin izlediği maskeleme spesifikasyonu [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) içinde uygulanmış ve belgelenmiştir.

## Rehberler

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — paketi eklemekten, maskelenmiş, saklanan ve dışa aktarılan loglara kadar.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — mesajların, metadata'nın, URL'lerin ve gövdelerin nasıl okunduğu ve nelerin bulunamadığı.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — depo sınırları, arşiv biçimleri, `ShareLink` ve özel sink'ler.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — `os.Logger`, swift-log, Pulse veya CocoaLumberjack'in ne zaman daha uygun olduğu.

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

CI, GitHub'ın `macos-26` runner imajındaki varsayılan Xcode ile derler. Paket Xcode 27 ile geliştirilmiştir.

## Mimari

```text
log.info(message, metadata)
  └─ MobileLogger ── level check, then RecordRedactor
       ├─ message   → SensitiveDataRedactor.redact(_:)          free text, one cut point
       ├─ metadata  → one JSON object → redact(body:"application/json")
       │    ├─ .url  → redact(url:)    put back only where its key keeps it
       │    └─ .body → redact(body:contentType:)
       └─ LogRecord (redacted) → every LogSink
            ├─ OSLogSink        os.Logger, public
            ├─ MemoryLogStore   count + byte budget
            └─ FileLogStore     rotating JSON Lines → LogArchive → ShareLink
```

- `Sources/MobileLogger` logger'ı, kayıt türlerini, sink'leri (`Sinks/`) ve dışa aktarımı (`Export/`) içerir. `Sources/MobileLoggerSwiftLog` swift-log handler'ını içerir; swift-log kullanmayan uygulamaların onu bağlamaması için ayrı bir üründür.
- Maskeleme, herhangi bir sink çağrılmadan önce, loglamayı yapan thread üzerinde bir kez gerçekleşir. Sink'ler yalnızca `LogRecord` değerlerini görür; bu yüzden yeni bir sink, maskeleyicinin gizlediğini sızdıramaz.
- URL'ler ve gövdeler önce kendi ayrıştırıcılarıyla maskelenir. Ardından metadata JSON'u, onların yerinde bu metinle okunur; böylece bir URL veya gövde, komşularını diğer her string gibi gizler. Sonra bir kez de onların yerinde bir yedek sözcükle okunur: metin komşularına bir sırrı adlandırıyorsa sırrı adlandıran bir sözcük, değilse nötr bir işaret. URL'nin veya gövdenin metni yalnızca bu sözcüğün değişmeden geri geldiği yerde (anahtarı ve komşuları hiçbir şey gizlemiyorsa) korunur; başka her yerde değer gizli kalır. Bu yüzden ilki `password` okunan iki gövdelik bir çift, tıpkı iki string'lik bir çift gibi ikincisini gizler. Bir URL veya gövde ayrıca verildiği hâliyle de okunur; bu yüzden ayrıştırıcısının yeniden yazdığı bir ad (`<unparsed URL>` olarak yazılan göreli URL `password`) yanındakini yine gizler.
- Her sınır fail-closed çalışır: sınır aşıldığında logger daha fazlasını gizler veya atar, asla daha azını; attığı kayıtları da sayar.
- Testler Swift Testing kullanır ve macOS'ta ve bir iPhone simülatöründe çalışır: spesifikasyonun zorunlu seti ve korpusu, metadata hattı, depolar, dışa aktarım, swift-log köprüsü, README örnekleri ve `OSLogStore` ile unified logging üzerinden gidip gelen bir tur.

Testleri yerelde çalıştırın:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Yol haritası

- Örnek uygulamanın listesinden geliştirilmiş, hazır bir SwiftUI log görüntüleyici.
- `FileLogStore` için, boyut ve adet sınırlarının yanında zamana dayalı saklama süresi.
- Paketin Swift Package Index'e eklenmesi; `.spi.yml` zaten depoda bulunuyor.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
