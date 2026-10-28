<!-- i18n-source: README.md@d9de57463180a0f24deae8e38d6a6e79f81f6be3 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/banner-light.svg" alt="MobileLogger: Logging for Apple apps that hides secrets before anything is written, then keeps and exports the logs."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/MobileLogger/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/MobileLogger/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 18+ · macOS 15+ · tvOS 18+ · watchOS 11+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/MobileLogger/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/MobileLogger/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

O MobileLogger é um pacote Swift de logging estruturado para apps iOS, macOS, tvOS, watchOS e visionOS que oculta segredos antes que qualquer coisa seja escrita. Cada mensagem e cada valor de metadata passa pelo mascarador de uma especificação de mascaramento compartilhada e escrita, de modo que o unified logging, os armazenamentos no dispositivo e um arquivo exportado contêm o mesmo texto seguro. Ele é voltado a equipes de apps cujos logs saem do dispositivo: anexados a relatórios de bug, enviados pelo suporte ou lidos a partir de um sysdiagnose. Ele escreve no `os.Logger`, mantém os logs na memória ou no disco dentro de limites fixos, exporta-os para o `ShareLink` e também mascara os logs de pacotes que usam o swift-log.

## Destaques

- **Mascaramento em todos os caminhos** — mensagens, chaves e valores de metadata, URLs e corpos HTTP passam pelo `SensitiveDataRedactor` do [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools), a implementação de referência da especificação de mascaramento: nomes de segredos, números de cartão (Luhn), IBANs (mod-97), endereços de e-mail, JSON Web Tokens, tokens bearer e tokens longos.
- **Verificado com a especificação** — o conjunto de testes obrigatório da especificação e seu corpus de 7.866 entradas adversárias passam pelos pontos de entrada do próprio logger; a saída deve ser igual à do mascarador de referência para cada entrada, e a exportação não pode acrescentar o que oculta.
- **Limites fail-closed** — mensagens grandes demais, metadata aninhada em mais de 64 níveis, maior que 256 KiB ou com mais de 256 KiB de URLs e corpos, e URLs longas demais são ocultadas por inteiro em vez de lidas pela metade; NaN, infinito e `Int.min` nunca causam trap.
- **Armazenamentos limitados** — o `MemoryLogStore` mantém os registros mais recentes dentro de um orçamento de quantidade e de bytes, o `FileLogStore` rotaciona um número fixo de arquivos JSON Lines, e ambos contam o que descartam em vez de crescer.
- **Exportação pronta para compartilhar** — o `LogArchive` escreve JSON Lines ou texto, filtrados por nível e data, e está em conformidade com `Transferable` para o `ShareLink`.
- **Ponte com o swift-log** — o `RedactingLogHandler` envia os logs de todos os pacotes que usam o swift-log pelo mesmo mascarador e pelos mesmos armazenamentos.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Cole-o no campo de busca no canto superior direito da janela. Deixe **Dependency Rule** em **Up to Next Major Version** a partir de `2.0.0` e clique em **Add Package**. Na janela seguinte, escolha o target do seu app ao lado de **MobileLogger** e clique em **Add Package** de novo.

**2. Importe o módulo**

```swift
import MobileLogger
```

Coloque esta linha no topo do arquivo Swift em que você registra logs.

**3. Use**

Crie um logger por funcionalidade e registre uma mensagem cujos dados estejam na metadata:

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

Chame `quickStart()` a partir de um botão ou de `.task`, execute o app e olhe o console do Xcode.

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/MobileLogger.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

O pacote depende do [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools) (o mascarador) e do [swift-log](https://github.com/apple/swift-log) (usado apenas pelo produto `MobileLoggerSwiftLog`).

## Uso

Os exemplos abaixo foram copiados de [`ReadmeSamples.swift`](Examples/LogExplorer/LogExplorer/ReadmeSamples.swift) e [`ReadmeSwiftLogSample.swift`](Examples/LogExplorer/LogExplorer/ReadmeSwiftLogSample.swift), que o app de exemplo e os testes compilam; os testes conferem cada saída indicada nos comentários.

### Escrever mensagens e metadata

Uma mensagem é texto livre com um único ponto de corte: a primeira chave que não é permitida, ou o primeiro nome de segredo, oculta o restante. Mantenha a mensagem como uma frase constante e coloque os valores na metadata, onde cada chave é avaliada separadamente.

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

### Registrar URLs e corpos HTTP

`.url` remove o nome de usuário, a senha e o fragmento, troca os identificadores do caminho por `:id` e oculta os valores da query. `.body` lê corpos JSON, de formulário, multipart e de texto simples de acordo com o content type e omite qualquer outro corpo.

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

### Manter os logs e exportá-los

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

Entregue o arquivo ao `ShareLink(item: archive, preview: SharePreview(archive.fileName))` ou grave-o em uma pasta com `archive.write(to:)`.

### Passar o swift-log pelo mascarador

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

### Permitir mais onde você precisar

Os padrões ocultam o máximo. Uma `RedactionPolicy` pode deixar passar mais, mas não consegue desativar a regra de nomes de segredos nem os detectores.

```swift
func policy() -> MobileLogger {
    let policy = RedactionPolicy(
        allowedTextKeys: ["screen", "attempt"],  // read on after these keys in messages
        allowedQueryParameters: ["page", "sort"] // keep these query values in URLs
    )
    return MobileLogger(category: "Catalog", policy: policy, sinks: [OSLogSink(), MemoryLogStore()])
}
```

## Quando usar outra coisa

| Você precisa de                                         | Use                                                                                                                                        |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Uma API de logging para uma biblioteca que você publica | [swift-log](https://github.com/apple/swift-log); os apps então o passam pelo `RedactingLogHandler`                                         |
| Um inspetor de rede com interface de console            | [Pulse](https://github.com/kean/Pulse); ele mascara apenas os headers, os itens de query e os campos JSON que você nomear, não as mensagens |
| Logs que nunca saem do unified logging                  | `os.Logger` com `privacy:` em cada interpolação                                                                                            |
| Uma base de código Objective-C que já o usa             | [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)                                                                      |
| Logging em servidores Linux                             | swift-log com um handler de servidor; o MobileLogger usa OSLog e roda apenas em plataformas Apple                                          |

O artigo [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) explica cada caso e como combiná-los.

## Demonstração

| Claro                                                                                        | Escuro                                                                                       |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| ![LogExplorer mostrando registros mascarados, modo claro](docs/images/log-explorer-light.png) | ![LogExplorer mostrando registros mascarados, modo escuro](docs/images/log-explorer-dark.png) |

O app de exemplo [LogExplorer](Examples/LogExplorer) registra quatro eventos que carregam segredos, do jeito que os apps costumam fazer por engano, e lista o que os seus sinks receberam. Abra `Examples/LogExplorer/LogExplorer.xcodeproj` no Xcode, escolha um simulador de iPhone ou **My Mac**, pressione **Run** e registre eventos com o botão **+**; o botão de compartilhar os exporta. As capturas de tela são feitas a partir do app por [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh); o [Examples/README.md](Examples/README.md) traz os detalhes.

## Documentação

Referência da API e artigos:

- [API reference](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/) — todos os tipos públicos, gerados com DocC e publicados pelo workflow de documentação.
- A especificação de mascaramento que o pacote segue está implementada e documentada no [iOSSecurityTools](https://github.com/muhittincamdali/iOSSecurityTools).

## Guias

- [Getting started](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/gettingstarted) — de adicionar o pacote até logs mascarados, mantidos e exportados.
- [Redaction rules](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/redactionrules) — como mensagens, metadata, URLs e corpos são lidos, e o que não é encontrado.
- [Exporting logs](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/exportinglogs) — limites dos armazenamentos, formatos de arquivo, `ShareLink` e sinks personalizados.
- [Choosing a logger](https://muhittincamdali.github.io/MobileLogger/documentation/mobilelogger/choosingalogger) — quando `os.Logger`, swift-log, Pulse ou CocoaLumberjack se encaixa melhor.

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| tvOS | 18 |
| watchOS | 11 |
| visionOS | 2 |
| Ferramentas | Swift 6.2 · Xcode 26+ |

O CI compila com o Xcode padrão da imagem de runner `macos-26` do GitHub. O pacote é desenvolvido com o Xcode 27.

## Arquitetura

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

- `Sources/MobileLogger` contém o logger, os tipos de registro, os sinks (`Sinks/`) e a exportação (`Export/`). `Sources/MobileLoggerSwiftLog` contém o handler do swift-log, um produto separado para que apps sem swift-log não o vinculem.
- A mascaramento acontece uma única vez, na thread que registra o log, antes de qualquer sink ser chamado. Os sinks só veem valores `LogRecord`, então um sink novo não consegue vazar o que o mascarador ocultou.
- URLs e corpos são mascarados primeiro pelos próprios parsers. Depois, o JSON da metadata é lido com esse texto no lugar deles, de modo que uma URL ou um corpo oculta suas vizinhas como qualquer outra string, e uma segunda vez com uma palavra substituta no lugar deles: uma palavra que nomeia um segredo onde o texto nomeia um para suas vizinhas, e um marcador neutro nos demais casos. Só onde essa palavra volta inalterada (sua chave e suas vizinhas não ocultam nada) o texto da URL ou do corpo é mantido; em qualquer outro lugar, o valor continua oculto. Por isso, um par de corpos cujo primeiro diz `password` oculta o segundo, como um par de strings faria. Uma URL ou um corpo também é lido como foi recebido, então um nome que o parser reescreve (a URL relativa `password`, escrita como `<unparsed URL>`) continua ocultando o que está ao lado.
- Todo limite é fail-closed: ao passar dele, o logger oculta ou descarta mais, nunca menos, e conta o que descarta.
- Os testes usam o Swift Testing e rodam no macOS e em um simulador de iPhone: o conjunto obrigatório e o corpus da especificação, o pipeline da metadata, os armazenamentos, a exportação, a ponte com o swift-log, os exemplos do README e uma ida e volta pelo unified logging com `OSLogStore`.

Execute os testes localmente:

```sh
swift test                                    # macOS
xcodebuild test -scheme MobileLogger-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Roteiro

- Um visualizador de logs em SwiftUI pronto para uso, construído a partir da lista do app de exemplo.
- Retenção por tempo para o `FileLogStore`, além dos limites de tamanho e de quantidade.
- Adicionar o pacote ao Swift Package Index; o `.spi.yml` já está no repositório.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/MobileLogger/blob/main/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/MobileLogger/blob/main/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
