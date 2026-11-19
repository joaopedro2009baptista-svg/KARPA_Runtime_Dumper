# KARPA Runtime Dumper — checklist de aceitação revisado

## Conclusão executiva

A entrega atual **não satisfaz integralmente** a especificação mestre e não deve ser descrita como uma ferramenta production-quality completa. Ela agora contém coleta Objective-C, snapshot Mach-O defensivo, monitor básico de imagens/classes, diff básico, CSV, dependency report de imagens, diagnóstico e exportação adicional. Ainda não contém a DYLIB compilada, projeto Xcode completo, análise ARM64, Swift inspector, dependency graph completo, UI ou todos os formatos pedidos.

`PASS` significa que existe implementação correspondente no source. `PARTIAL` significa que existe apenas uma parte segura ou simplificada. `NOT IMPLEMENTED` significa que não existe módulo funcional correspondente.

## Matriz

| Área | Status | Evidência / lacuna |
|---|---|---|
| Biblioteca independente sem Watusi/rede/telemetria | PASS | Source não importa Watusi, não usa rede e coleta somente mediante API explícita. |
| Target iOS/ARM64/ARM64e | PARTIAL | `.xcconfig` declara slices, mas não houve compilação ou validação no Xcode. |
| iOS mínimo | PARTIAL | Declarado como iOS 13.0 no `.xcconfig`; não validado contra APIs reais de cada SDK. |
| Detecção de OS/arquitetura | PARTIAL | `KARPADiagnosticsReport` registra OS, versão, arquitetura via `uname` e bundle ID; ainda não foi executado em iOS. |
| ESign/injeção/WhatsApp | NOT IMPLEMENTED | Não há fluxo de injeção; README expressamente limita o uso a alvo próprio/autorizado. |
| DYLIB genuinamente compilada | NOT IMPLEMENTED | O ambiente não possui Xcode/iOS SDK; somente source foi entregue. |
| Classes Objective-C | PASS | `objc_getClassList`, nome, superclass, metaclass, imagem, instance size e contagem. |
| Métodos de instância/classe | PASS | Listas diretas; opção recursiva de herdados com campo `direct`. |
| Encodings/IMP/imagem | PASS | Encoding bruto, IMP textual e `dladdr` quando resolvível. |
| Erros por classe/availability | PARTIAL | Há algumas falhas globais, mas não há isolamento e registro detalhado por classe. |
| Propriedades | PARTIAL | Nome e attribute string; não há parser completo de getter/setter/readonly/weak/copy/strong. |
| Ivars | PASS | Nome, encoding, offset e instance size da classe. |
| Protocolos | PARTIAL | Coleta métodos required/optional de instância/classe, propriedades e protocolos herdados diretamente; ainda não agrega toda a hierarquia transitiva. |
| Categorias | NOT IMPLEMENTED | Não há enumeração/relatório de categorias. |
| Swift runtime | PARTIAL | `KARPASwiftInspector` identifica imagens por nome e marca explicitamente metadata parcial; não faz reflexão completa. |
| Mach-O paths/UUID/cpu/file type | PASS | Implementado para imagens carregadas 64-bit. |
| Load commands/segments/sections | PARTIAL | Agora lista comandos, segmentos e sections com validação para Mach-O 64-bit little-endian; não cobre 32-bit/big-endian. |
| Símbolos/exportações/frameworks | NOT IMPLEMENTED | Não há parser de export trie, symbol table ou framework mapper. |
| Objective-C sections Mach-O | NOT IMPLEMENTED | Não correlaciona `__objc_*` com runtime. |
| Runtime/file/image-relative addresses | PARTIAL | IMP, imagem, slide, UUID da imagem e status de parsing são reportados; faltam correlação completa de offset de arquivo por método. |
| ARM64/ARM64e/PAC | NOT IMPLEMENTED | Nenhum analisador de instruções, PAC ou boundaries. |
| DYLD image monitor | PARTIAL | `KARPAImageMonitor` registra callbacks de add-image; unload, path exato no callback e histórico persistente ainda faltam. |
| Class registration monitor | PARTIAL | `KARPAClassMonitor` compara snapshots periódicos e detecta nomes adicionados/removidos; mudanças de metadata ainda faltam. |
| Runtime mutation detector | PARTIAL | `KARPAComputeRuntimeDiff` detecta classes, hierarquia, métodos e IMPs; propriedades, protocols e encodings precisam ser ampliados. |
| Selector cross-reference | PARTIAL | `KARPACrossReference` gera `selector_index.json` com selector→classes→IMP→images e relações de superclass/protocol; referências de instruções ainda faltam. |
| Type encoding parser | PARTIAL | Tokenização conservadora básica; faltam parser estrutural robusto, offsets, arrays/unions/nested completos e testes. |
| Block signature inspector | PARTIAL | O parser marca `@?` e declara `NOT_RECOVERED_FROM_METHOD_ENCODING`; assinatura/captures reais ainda não são recuperados. |
| Dependency mapper | PARTIAL | `dependency_report.json` mapeia imagens, UUIDs e dependências load-command; grafo de classes/métodos/seletores ainda falta. |
| Binary-to-runtime mapper | PARTIAL | Imagem da IMP é resolvida quando possível; não há correlação completa runtime↔Mach-O/file offset/symbol. |
| Media investigation | PARTIAL | Filtro por nomes/seletores com aviso de que é heurístico; não faz descoberta completa de dependências ou relatórios individuais. |
| FRMediaItem etc. | PARTIAL | O código pode encontrar classes presentes no processo, mas não tem inventário específico, cross-reference ou análise de implementação equivalente à análise estática anterior. |
| Runtime diff | PARTIAL | Diff v2 compara classes, hierarquia, métodos, IMPs, encodings, properties e protocols; API persistente existe, mas não há UI de seleção de snapshots. |
| Full/filtered collection engine | PARTIAL | Uma chamada síncrona; há `mediaOnly`, mas não há start/pause/resume/stop/repeat/compare. |
| Concorrência/cancelamento | PARTIAL | APIs não iniciam automaticamente, mas a coleta é síncrona e não existe job/cancelamento. |
| Relatórios JSON/TXT | PASS | Gera `runtime_dump.json`, `runtime_dump.txt`, `coverage_report.json` e `media_investigation.json`, sujeito a build/teste iOS. |
| CSV | PARTIAL | `KARPAExporter` gera `runtime_dump.csv`; ainda não há teste real nem exportação por UI. |
| `mach_o_report.json` separado | PASS | `KARPAStorage` agora grava o snapshot de imagens em arquivo separado. |
| `dependency_report.json` | PARTIAL | Arquivo é gerado para dependências de imagens; grafo completo ainda falta. |
| `runtime_diff.json` | PARTIAL | O cálculo de diff existe; gravação automática e comparação de múltiplos arquivos ainda faltam. |
| `collection_errors.txt` | NOT IMPLEMENTED | Erros não são gravados nesse arquivo. |
| ZIP/export/share sheet | PARTIAL | ZIP sem compressão é gerado por `KARPAZipExporter`; share sheet é fornecido pelo controller UIKit, mas não foi compilado/testado em iOS. |
| UI nativa | PARTIAL | `KARPAInterfaceViewController` possui ações reais de full/media dump, cancelamento solicitado e share sheet; pause/resume real e teste iOS faltam. |
| Diagnóstico e recovery | PARTIAL | Diagnóstico registra OS/arquitetura/bundle e status de validação; ainda faltam isolamento por classe, memory pressure e logs estruturados. |
| Coverage/integrity | PARTIAL | Coverage inclui contagens e diagnóstico OS/arquitetura/bundle/status; faltam skipped/errors detalhados, duração, UUID principal e hashes. |
| Arquitetura modular | PARTIAL | Alguns módulos existem, mas muitos componentes da arquitetura especificada faltam. |
| Build scripts/configuração | PARTIAL | Há `.xcconfig` e README; não há projeto Xcode, script de build ou testes compiláveis neste ambiente. |
| Testes reais | NOT IMPLEMENTED | Apenas verificação estática do source; não houve build ou execução em iOS. |
| ZIP completo com exemplos | PARTIAL | Existe ZIP do source, mas não há projeto Xcode completo, DYLIB, exemplos de reports ou resultados de dispositivo. |

## Problemas técnicos encontrados na revisão

1. `KARPAOptions.outputDirectory` é apenas armazenado; a coleta usa o diretório recebido por `KARPACollectToDirectory`. Isso é aceitável como API, mas o campo não controla a escrita sozinho.
2. A função principal retorna um único dicionário agregado. Ela não cria a estrutura `FULL/FILTERED/MEDIA/MACH_O/DIFF/LOGS` pedida.
3. `KARPAInspectLoadedImages` cobre imagens 64-bit e segmentos, mas não implementa sections, exportações, símbolos ou ranges executáveis/escritos.
4. O filtro de mídia é deliberadamente heurístico. Um nome ou selector contendo `video`, `photo`, `save` ou `download` não comprova comportamento.
5. Não há testes Objective-C/XCTest para encodings complexos, callbacks, erros, diff ou exportação.
6. A definição de `KARPA_AUTOSTART` gera uma coleta no construtor, mas isso não é um monitor nem um mecanismo de injeção e não foi testado em iOS.

## Veredito

A entrega atual deve ser rotulada como **prototype/source core — PARTIAL**, não como implementação completa do prompt. Ela atende parcialmente ao núcleo seguro de coleta runtime e exportação local, mas não atende aos critérios de DYLIB compilada, produção, monitoramento, diff, análise binária avançada, UI e pacote de entrega completo.
