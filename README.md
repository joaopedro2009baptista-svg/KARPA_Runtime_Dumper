# KARPA Runtime Dumper — source

Biblioteca Objective-C para inspeção local e somente leitura do processo hospedeiro autorizado. O código usa APIs públicas de Objective-C runtime, Foundation e dyld. Não altera métodos, não faz swizzling, não instala hooks, não acessa conversas, credenciais ou tokens e não transmite dados pela rede.

## Build no macOS/Xcode

1. Crie um target **Dynamic Library** iOS em um projeto Xcode.
2. Adicione todos os arquivos `.h` e `.m` deste diretório ao target.
3. Defina `MACH_O_TYPE = mh_dylib`, `IPHONEOS_DEPLOYMENT_TARGET = 13.0` e `ARCHS = arm64 arm64e` conforme suporte do Xcode.
4. Compile em um dispositivo e aplicativo de teste próprios/autorizados. A biblioteca não é um app e não deve ser assinada como um executável independente.
5. Verifique o produto com `file`, `otool -hv`, `otool -L` e a assinatura do seu ambiente.

A biblioteca não inicia coleta automaticamente. O aplicativo autorizado deve chamar `KARPACollectToDirectory` explicitamente. Para um teste controlado, adicione `GCC_PREPROCESSOR_DEFINITIONS = $(inherited) KARPA_AUTOSTART=1`; nesse modo opcional a saída vai para `NSTemporaryDirectory()/KARPA_DUMPS`. O construtor não modifica métodos, mas não deve ser usado em produção porque executa coleta durante o carregamento.

## Exemplo de chamada

```objc
#import "KARPARuntimeDumper.h"
KARPAOptions *o = [KARPAOptions defaultOptions];
o.mediaOnly = YES;
o.outputDirectory = [documents stringByAppendingPathComponent:@"KARPA_DUMPS"];
NSError *error = nil;
BOOL ok = KARPACollectToDirectory(o, o.outputDirectory, &error);
```

## Relatórios

- `runtime_dump.json`: classes, métodos, propriedades, ivars, protocolos e encodings.
- `runtime_dump.txt`: resumo legível.
- `runtime_dump.csv`: linhas de classe/método para análise tabular.
- `mach_o_report.json`: imagens carregadas, UUIDs, load commands, segmentos, sections e dependências observáveis.
- `dependency_report.json`: dependências de imagens com classificação `STATIC_BINARY_CONFIRMED`.
- `selector_index.json`: índice reverso de selector para classes, encodings, IMPs e imagens.
- `swift_report.json`: identificação limitada de imagens cujo nome sugere Swift; não é reflexão completa.
- `media_investigation.json`: subconjunto baseado em evidência de nomes de classe/selector.
- `coverage_report.json`: contagens, diagnóstico e limitações.
- `collection_history.json`: histórico local append-only das coletas concluídas.
- `KARPA_DUMPS.zip`: arquivo ZIP local dos relatórios gerados.

Os módulos `KARPAImageMonitor`, `KARPAClassMonitor`, `KARPACrossReference`, `KARPASwiftInspector` e `KARPARuntimeDiff` fornecem, respectivamente, observação básica de add-image, snapshots periódicos de classes, índice reverso de selectors, identificação limitada de imagens Swift e comparação de dumps. Eles ainda são módulos de source e não foram compilados ou testados em dispositivo neste ambiente.

## Limitações

APIs públicas não enumeram necessariamente categorias não registradas, metadata Swift completa, todos os símbolos ou todos os limites de função. O código marca cobertura e não transforma inferências em confirmações. Não há suporte declarado para injeção em aplicativos de terceiros, bypass de assinatura, jailbreak ou ESign; teste apenas em um alvo sob seu controle e de acordo com a autorização aplicável.
