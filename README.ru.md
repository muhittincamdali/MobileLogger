<!-- i18n-source: README.md@43d53ade180b6e450947731fe13ec0fabeb33c68 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

MobileLogger — это Swift-пакет для структурированного логирования в приложениях для iOS, macOS, tvOS, watchOS и visionOS, который скрывает секреты до того, как что-либо будет записано. Каждое сообщение и каждое значение metadata проходит через маскировщик (redactor) общей письменной спецификации маскирования, поэтому unified logging, хранилища на устройстве и экспортированный файл содержат один и тот же безопасный текст. Пакет предназначен для команд, чьи логи покидают устройство: их прикладывают к отчётам об ошибках, отправляют из поддержки или читают из sysdiagnose. Он пишет в `os.Logger`, хранит логи в памяти или на диске в пределах заданных лимитов, экспортирует их для `ShareLink` и маскирует также логи пакетов, которые используют swift-log.

## Основные возможности

- **Маскирование на каждом пути** — сообщения, ключи и значения metadata, URL и тела HTTP-запросов проходят через `SensitiveDataRedactor` из [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) — эталонной реализации спецификации маскирования: имена секретов, номера карт (Luhn), IBAN (mod-97), адреса электронной почты, JSON Web Token, bearer-токены и длинные токены.
- **Проверка по спецификации** — обязательный набор тестов спецификации и её корпус из 7 866 враждебных входных данных прогоняются через собственные точки входа логгера; для каждого входа результат должен совпадать с результатом эталонного маскировщика, а экспорт не должен добавлять то, что скрыто.
- **Fail-closed лимиты** — слишком большие сообщения, metadata с вложенностью более 64 уровней, размером более 256 KiB или с URL и телами общим объёмом более 256 KiB, а также слишком длинные URL скрываются целиком, а не читаются наполовину; NaN, бесконечность и `Int.min` никогда не приводят к trap.
- **Ограниченные хранилища** — `MemoryLogStore` хранит самые новые записи в пределах бюджета по числу записей и байтам, `FileLogStore` ротирует фиксированное число файлов JSON Lines, а оба считают отброшенное, вместо того чтобы расти.
- **Экспорт, готовый к отправке** — `LogArchive` записывает JSON Lines или текст с фильтрацией по уровню и дате и поддерживает `Transferable` для `ShareLink`.
- **Мост для swift-log** — `RedactingLogHandler` направляет логи каждого пакета, использующего swift-log, через тот же маскировщик и те же хранилища.

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Вставьте его в поле поиска в правом верхнем углу окна. Оставьте для **Dependency Rule** значение **Up to Next Major Version** от `2.0.0` и нажмите **Add Package**. В следующем окне выберите таргет вашего приложения рядом с **MobileLogger** и снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import MobileLogger
```

Поместите эту строку в начало Swift-файла, где вы пишете логи.

**3. Используйте**

Создайте по одному логгеру на каждую функциональность и запишите сообщение, данные которого лежат в metadata:

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

Вызовите `quickStart()` из кнопки или `.task`, запустите приложение и посмотрите консоль Xcode.

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

Пакет зависит от [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) (маскировщик) и [swift-log](https://github.com/apple/swift-log) (используется только продуктом `MobileLoggerSwiftLog`).

## Использование

Примеры ниже скопированы из [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) и [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift), которые компилируют демонстрационное приложение и тесты; тесты проверяют каждый результат, указанный в комментариях.

### Запись сообщений и metadata

Сообщение — это свободный текст с единственной точкой отсечения: первый недопустимый ключ или первое имя секрета скрывает всё, что идёт после него. Оставляйте сообщение постоянной фразой, а значения помещайте в metadata, где каждый ключ оценивается отдельно.

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

### Логирование URL и тел HTTP-запросов

`.url` убирает имя пользователя, пароль и фрагмент, заменяет идентификаторы в пути на `:id` и скрывает значения параметров запроса. `.body` читает тела JSON, формы, multipart и обычного текста в соответствии с их content type, а любые другие тела опускает.

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

### Хранение логов и их экспорт

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

Передайте архив в `ShareLink(item: archive, preview: SharePreview(archive.fileName))` или запишите его в папку с помощью `archive.write(to:)`.

### Пропуск swift-log через маскировщик

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

### Разрешить больше там, где это нужно

По умолчанию скрывается как можно больше. `RedactionPolicy` может пропустить больше, но не может отключить правило имён секретов и детекторы.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## Когда лучше выбрать другое

| Вам нужно                                               | Используйте                                                                                                                                |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| API логирования для библиотеки, которую вы публикуете   | [swift-log](https://github.com/apple/swift-log); приложения затем пропускают его через `RedactingLogHandler`                               |
| Сетевой инспектор с консольным интерфейсом              | [Pulse](https://github.com/kean/Pulse); он маскирует только заголовки, параметры запроса и поля JSON, которые вы назовёте, но не сообщения |
| Логи, которые никогда не покидают unified logging       | `os.Logger` с `privacy:` в каждой интерполяции                                                                                             |
| Кодовая база на Objective-C, которая уже его использует | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                                      |
| Логирование на серверах Linux                           | swift-log с серверным обработчиком; MobileLogger использует OSLog и работает только на платформах Apple                                    |

В статье [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) разобран каждый случай и способы их сочетания.

## Демо

| Светлая                                                                                            | Тёмная                                                                                           |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| ![LogExplorer показывает замаскированные записи, светлая тема](docs/images/log-explorer-light.png) | ![LogExplorer показывает замаскированные записи, тёмная тема](docs/images/log-explorer-dark.png) |

Демонстрационное приложение [LogExplorer](Examples/LogExplorer) записывает в лог четыре события с секретами — так, как приложения нередко делают по ошибке, — и показывает список того, что получили его sink-и. Откройте `Examples/LogExplorer/LogExplorer.xcodeproj` в Xcode, выберите симулятор iPhone или **My Mac**, нажмите **Run** и записывайте события кнопкой **+**; кнопка отправки экспортирует их. Скриншоты снимает из приложения [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh); подробности — в [Examples/README.md](Examples/README.md).

## Документация

Справочник API и статьи:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — каждый публичный тип; собрано с помощью DocC и опубликовано workflow документации.
- Спецификация маскирования, которой следует пакет, реализована и описана в [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools).

## Руководства

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — от добавления пакета до логов, которые маскируются, хранятся и экспортируются.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — как читаются сообщения, metadata, URL и тела запросов и что не обнаруживается.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — лимиты хранилищ, форматы архивов, `ShareLink` и собственные sink-и.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — когда лучше подходят `os.Logger`, swift-log, Pulse или CocoaLumberjack.

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| Инструменты | Swift 6.2 · Xcode 26+ |

CI собирает проект в Xcode по умолчанию из образа раннера `macos-26` на GitHub. Пакет разрабатывается в Xcode 27.

## Архитектура

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

- `Sources/MobileLogger` содержит логгер, типы записей, sink-и (`Sinks/`) и экспорт (`Export/`). `Sources/MobileLoggerSwiftLog` содержит обработчик swift-log; это отдельный продукт, чтобы приложения без swift-log не линковали его.
- Маскирование выполняется один раз, в потоке, который пишет лог, до вызова любого sink. Sink-и видят только значения `LogRecord`, поэтому новый sink не может раскрыть то, что скрыл маскировщик.
- URL и тела сначала маскируются собственными парсерами. Затем JSON с metadata читается с этим текстом на их месте, поэтому URL или тело скрывает соседние значения, как любая другая строка, и ещё раз со словом-заменителем на их месте: словом, которое называет секрет, там, где текст называет секрет соседним значениям, и нейтральным маркером в остальных случаях. Только там, где это слово возвращается без изменений (его ключ и соседние значения ничего не скрывают), текст URL или тела сохраняется; в любом другом месте значение остаётся скрытым. Поэтому пара тел, первое из которых читается как `password`, скрывает второе, как и пара строк. Кроме того, URL или тело читается в том виде, в каком оно передано, поэтому имя, которое переписывает его парсер (относительный URL `password`, записанный как `<unparsed URL>`), всё равно скрывает соседнее значение.
- Каждый лимит работает по принципу fail-closed: при его превышении логгер скрывает или отбрасывает больше, но никогда не меньше, и считает отброшенное.
- Тесты используют Swift Testing и запускаются на macOS и в симуляторе iPhone: обязательный набор и корпус спецификации, конвейер metadata, хранилища, экспорт, мост для swift-log, примеры из README и полный цикл через unified logging с `OSLogStore`.

Запустите тесты локально:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## План развития

- Готовый просмотрщик логов на SwiftUI, собранный на основе списка из демонстрационного приложения.
- Хранение логов с ограничением по времени для `FileLogStore` — в дополнение к лимитам по размеру и количеству.
- Добавление пакета в Swift Package Index; `.spi.yml` уже есть в репозитории.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
