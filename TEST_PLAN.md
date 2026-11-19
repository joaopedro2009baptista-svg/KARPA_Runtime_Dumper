# KARPA test plan

## Build checks

- Build `Debug` e `Release` para `arm64`; adicionar `arm64e` somente quando o Xcode/SDK do dispositivo suportar o slice.
- Confirmar `MACH_O_TYPE=mh_dylib`, deployment target, UUID e dependências com `otool -hv -L`.
- Confirmar que não existem referências a Watusi, rede, swizzling, `MSHookFunction`, `Substrate` ou APIs privadas.

## Runtime checks em app próprio

- Chamar `KARPACollectToDirectory` no thread de background.
- Verificar JSON válido e contagens não nulas.
- Verificar classes, métodos, propriedades, ivars e protocolos.
- Verificar `direct=false` quando `includeInheritedMethods=YES`.
- Verificar imagens carregadas, UUID, slide e dependências.
- Verificar filtro `mediaOnly=YES` e o campo de classificação `STATIC_RUNTIME_METADATA_CONFIRMED`.
- Verificar cancelamento do app e falhas de diretório sem encerrar o host.
- Comparar dois dumps preservando os arquivos originais.

## Limitações esperadas

- Categorias e Swift metadata podem ser incompletos.
- `dladdr` pode não resolver o arquivo de uma IMP.
- Dados de Mach-O dependem das imagens carregadas e dos load commands visíveis.
- O módulo não infere comportamento de um selector apenas pelo nome.
