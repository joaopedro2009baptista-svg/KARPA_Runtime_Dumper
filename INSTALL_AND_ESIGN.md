# Build, instalação e ESign

## Build reproduzível

O projeto contém o target `KARPA` em `KARPA.xcodeproj`, configurado como `com.apple.product-type.library.dynamic` com `MACH_O_TYPE = mh_dylib`, iOS mínimo 13.0 e build Release para `arm64`.

Em um Mac com Xcode e o iOS SDK instalado:

```sh
./build_ios.sh
```

O script gera `build/DerivedData/Build/Products/Release-iphoneos/libKARPA.dylib`, executa `validate_ios_binary.sh` e cria `build/KARPA_iOS_arm64_artifacts.zip`.

O workflow `.github/workflows/ios-build.yml` executa o mesmo processo em um runner macOS e publica a dylib, logs e ZIP em GitHub Actions Artifacts. O artifact não é um pacote assinado para distribuição.

## Assinatura e teste

A biblioteca deve ser integrada apenas a um aplicativo de teste próprio/autorizado. O binário precisa ser assinado novamente dentro do processo de assinatura do aplicativo, com a identidade, entitlements, Team ID e perfil de provisionamento compatíveis com o alvo. A dylib não é um aplicativo independente e não deve ser instalada como se fosse um `.ipa`.

Para um teste autorizado, o fluxo geral é:

1. Baixar o artifact do workflow concluído.
2. Conferir `file`, `otool -hv`, `otool -L` e os símbolos no `binary_validation.log`.
3. Integrar `libKARPA.dylib` ao app de teste e assinar o app inteiro pelo fluxo legítimo do ambiente.
4. Executar a coleta explicitamente via `KARPACollectToDirectory` em um processo sob controle do testador.
5. Validar os relatórios e conservar o log de assinatura e do dispositivo.

## ESign: avaliação honesta

A compatibilidade com ESign **não está verificada**. Este repositório não implementa bypass de assinatura, injeção em aplicativos de terceiros, jailbreak, carregamento oculto, acesso a credenciais/conversas ou rede. O sucesso em ESign depende do dispositivo, versão do iOS, assinatura lateral autorizada, entitlements, modo de carregamento e política vigente do ambiente. Não há garantia de que uma dylib assinada por esse fluxo carregará em um app não pertencente ao testador.

Até existir um build e teste real em dispositivo autorizado, os estados devem permanecer `COMPILED` apenas após o workflow produzir o Mach-O, `UNIT TESTED` somente após testes executados e `DEVICE TESTED` somente após evidência de execução no dispositivo.
