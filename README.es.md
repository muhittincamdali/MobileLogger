<!-- i18n-source: README.md@8e97ff5e024616dc4fc4a56edaa1f454b20857ec status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

MobileLogger es un paquete de Swift para el registro estructurado en apps de iOS, macOS, tvOS, watchOS y visionOS que oculta los secretos antes de que se escriba nada. Cada mensaje y cada valor de metadata pasa por el enmascarador de una especificación de enmascaramiento compartida y por escrito, de modo que unified logging, los almacenes del dispositivo y un archivo exportado contienen el mismo texto seguro. Está pensado para equipos de apps cuyos logs salen del dispositivo: adjuntos a informes de errores, enviados por soporte o leídos desde un sysdiagnose. Escribe en `os.Logger`, guarda los logs en memoria o en disco dentro de límites fijos, los exporta para `ShareLink` y también enmascara los logs de los paquetes que usan swift-log.

## Lo más destacado

- **Enmascaramiento en cada ruta** — los mensajes, las claves y los valores de metadata, las URL y los cuerpos HTTP pasan por `SensitiveDataRedactor` de [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools), la implementación de referencia de la especificación de enmascaramiento: nombres de secretos, números de tarjeta (Luhn), IBAN (mod-97), direcciones de correo electrónico, JSON Web Tokens, tokens bearer y tokens largos.
- **Verificado con la especificación** — el conjunto de pruebas obligatorio de la especificación y su corpus de 7.866 entradas adversarias se ejecutan a través de los puntos de entrada del propio logger; la salida debe ser igual a la del enmascarador de referencia para cada entrada, y la exportación no debe añadir lo que oculta.
- **Límites fail-closed** — los mensajes demasiado grandes, la metadata anidada a más de 64 niveles o de más de 256 KiB y las URL demasiado largas se ocultan por completo en lugar de leerse a medias; NaN, infinito e `Int.min` nunca provocan un trap.
- **Almacenes acotados** — `MemoryLogStore` conserva los registros más recientes dentro de un presupuesto de cantidad y de bytes, `FileLogStore` rota un número fijo de archivos JSON Lines, y ambos cuentan lo que descartan en lugar de crecer.
- **Exportación lista para compartir** — `LogArchive` escribe JSON Lines o texto, filtrados por nivel y fecha, y cumple `Transferable` para `ShareLink`.
- **Puente con swift-log** — `RedactingLogHandler` envía los logs de todos los paquetes que usan swift-log por el mismo enmascarador y los mismos almacenes.

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Pégala en el campo de búsqueda de la parte superior derecha de la ventana. Deja **Dependency Rule** en **Up to Next Major Version** desde `2.0.0` y haz clic en **Add Package**. En la ventana siguiente, elige el target de tu app junto a **MobileLogger** y haz clic de nuevo en **Add Package**.

**2. Importa el módulo**

```swift
import MobileLogger
```

Pon esta línea al principio del archivo Swift donde registras logs.

**3. Úsalo**

Crea un logger por funcionalidad y registra un mensaje cuyos datos estén en la metadata:

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

Llama a `quickStart()` desde un botón o desde `.task`, ejecuta la app y mira la consola de Xcode.

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

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

El paquete depende de [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) (el enmascarador) y de [swift-log](https://github.com/apple/swift-log) (solo lo usa el producto `MobileLoggerSwiftLog`).

## Uso

Los ejemplos de abajo están copiados de [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) y [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift), que la app de ejemplo y las pruebas compilan; las pruebas comprueban cada salida de los comentarios.

### Escribir mensajes y metadata

Un mensaje es texto libre con un único punto de corte: la primera clave que no está permitida, o el primer nombre de secreto, oculta el resto. Mantén el mensaje como una frase constante y pon los valores en la metadata, donde cada clave se juzga por separado.

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

### Registrar URL y cuerpos HTTP

`.url` elimina el nombre de usuario, la contraseña y el fragmento, sustituye los identificadores de la ruta por `:id` y oculta los valores de la consulta. `.body` lee cuerpos JSON, de formulario, multipart y de texto plano según su content type y omite cualquier otro cuerpo.

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

### Guardar los logs y exportarlos

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

Entrega el archivo a `ShareLink(item: archive, preview: SharePreview(archive.fileName))`, o escríbelo en una carpeta con `archive.write(to:)`.

### Pasar swift-log por el enmascarador

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

### Permitir más donde lo necesites

Los valores por defecto ocultan lo máximo. Una `RedactionPolicy` puede dejar pasar más, pero no puede desactivar la regla de nombres de secretos ni los detectores.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## Cuándo usar otra cosa

| Necesitas                                           | Usa                                                                                                                                        |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Una API de logging para una biblioteca que publicas | [swift-log](https://github.com/apple/swift-log); las apps lo pasan después por `RedactingLogHandler`                                       |
| Un inspector de red con interfaz de consola         | [Pulse](https://github.com/kean/Pulse); solo enmascara los headers, los elementos de consulta y los campos JSON que nombres, no los mensajes |
| Logs que nunca salen de unified logging             | `os.Logger` con `privacy:` en cada interpolación                                                                                           |
| Una base de código Objective-C que ya lo usa        | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                                      |
| Logging en servidores Linux                         | swift-log con un handler de servidor; MobileLogger usa OSLog y solo funciona en plataformas Apple                                          |

El artículo [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) explica cada caso y cómo combinarlos.

## Demo

| Claro                                                                                         | Oscuro                                                                                        |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| ![LogExplorer mostrando registros enmascarados, modo claro](docs/images/log-explorer-light.png) | ![LogExplorer mostrando registros enmascarados, modo oscuro](docs/images/log-explorer-dark.png) |

La app de ejemplo [LogExplorer](Examples/LogExplorer) registra cuatro eventos que llevan secretos, como suelen hacer las apps por error, y muestra lo que recibieron sus sinks. Abre `Examples/LogExplorer/LogExplorer.xcodeproj` en Xcode, elige un simulador de iPhone o **My Mac**, pulsa **Run** y registra eventos con el botón **+**; el botón de compartir los exporta. Las capturas de pantalla las toma de la app [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh); [Examples/README.md](Examples/README.md) tiene los detalles.

## Documentación

Referencia de la API y artículos:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — cada tipo público, generado con DocC y publicado por el workflow de documentación.
- La especificación de enmascaramiento que sigue el paquete está implementada y documentada en [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools).

## Guías

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — desde añadir el paquete hasta logs enmascarados, guardados y exportados.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — cómo se leen los mensajes, la metadata, las URL y los cuerpos, y qué no se detecta.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — límites de los almacenes, formatos de archivo, `ShareLink` y sinks personalizados.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — cuándo encajan mejor `os.Logger`, swift-log, Pulse o CocoaLumberjack.

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| Herramientas | Swift 6.2 · Xcode 26+ |

CI compila con el Xcode por defecto de la imagen de runner `macos-26` de GitHub. El paquete se desarrolla con Xcode 27.

## Arquitectura

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

- `Sources/MobileLogger` contiene el logger, los tipos de registro, los sinks (`Sinks/`) y la exportación (`Export/`). `Sources/MobileLoggerSwiftLog` contiene el handler de swift-log, un producto aparte para que las apps sin swift-log no lo enlacen.
- La enmascaramiento ocurre una sola vez, en el hilo que registra el log, antes de llamar a ningún sink. Los sinks solo ven valores `LogRecord`, así que un sink nuevo no puede filtrar lo que el enmascarador ocultó.
- En el JSON de la metadata, una URL o un cuerpo aparece como una palabra marcadora. Solo donde esa palabra vuelve sin cambios (su clave y sus vecinas no ocultan nada) se pone en su lugar la URL o el cuerpo enmascarado por separado; en cualquier otro sitio el valor sigue oculto.
- Todos los límites son fail-closed: al superarlos, el logger oculta o descarta más, nunca menos, y cuenta lo que descarta.
- Las pruebas usan Swift Testing y se ejecutan en macOS y en un simulador de iPhone: el conjunto obligatorio y el corpus de la especificación, el pipeline de metadata, los almacenes, la exportación, el puente con swift-log, los ejemplos del README y un recorrido completo por unified logging con `OSLogStore`.

Ejecuta las pruebas en local:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Hoja de ruta

- Un visor de logs en SwiftUI listo para usar, construido a partir de la lista de la app de ejemplo.
- Retención por tiempo para `FileLogStore`, junto a los límites de tamaño y de cantidad.
- Añadir el paquete al Swift Package Index; `.spi.yml` ya está en el repositorio.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
