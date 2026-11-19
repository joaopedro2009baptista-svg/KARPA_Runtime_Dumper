# KARPA — Build and compatibility report

## Environment inspected

The local execution environment is Linux ARM64. The required Apple/iOS tools are not present locally, so the real build was executed on GitHub Actions `macos-15` with Xcode 16.4 and the iPhoneOS 18.5 SDK.

The successful workflow produced a genuine iOS Mach-O dynamic library. No Linux `.so`, simulator binary or renamed artifact is presented as an iOS DYLIB.

## Status categories

- **SOURCE IMPLEMENTED:** source module exists and is integrated into the collection/export path where stated.
- **COMPILED:** verified by successful macOS GitHub Actions build and artifact validation.
- **UNIT TESTED:** not verified; no XCTest execution environment is available here.
- **DEVICE TESTED:** not verified; no iOS device is attached.
- **NOT VERIFIED:** behavior requires Xcode/SDK/device validation.

## Current source modules

| Feature | Source | Status | Validation |
|---|---|---|---|
| Objective-C classes/methods/properties/ivars | `KARPAObjectiveCInspector.m` | SOURCE IMPLEMENTED | STATIC SOURCE CHECK; COMPILED/DEVICE TESTED NOT VERIFIED |
| Protocol metadata | `KARPAObjectiveCInspector.m` | SOURCE IMPLEMENTED, PARTIAL | Required/optional and instance/class method metadata is coded; iOS build not verified |
| Mach-O images/UUID/load commands/segments/sections | `KARPAMachOInspector.m` | SOURCE IMPLEMENTED, PARTIAL | Defensive 64-bit little-endian parser; build/device not verified |
| Address/IMP/image-relative resolution | `KARPAObjectiveCInspector.m` | SOURCE IMPLEMENTED, PARTIAL | `dladdr` path coded; PAC behavior and device output not verified |
| Media candidate investigation | `KARPAMediaInvestigator.m` | SOURCE IMPLEMENTED, HEURISTIC | Selector/class matching only; no behavioral claim |
| Selector cross-reference | `KARPACrossReference.m` | SOURCE IMPLEMENTED | Integrated into `runtime_dump.json` and `selector_index.json`; not device tested |
| Swift image inspection | `KARPASwiftInspector.m` | SOURCE IMPLEMENTED, PARTIAL | Image-name evidence only; no Swift reflection claim |
| Type encoding/block marker | `KARPATypeEncodingParser.m` | SOURCE IMPLEMENTED, PARTIAL | `@?` is marked; actual block signatures are not recovered |
| Runtime diff | `KARPARuntimeDiff.m` | SOURCE IMPLEMENTED, PARTIAL | Classes, hierarchy, methods, IMPs, encodings, properties and protocols compared; not unit tested |
| Image monitor | `KARPAImageMonitor.m` | SOURCE IMPLEMENTED, PARTIAL | Add-image callback only; unload/path lifecycle not complete |
| Class monitor | `KARPAImageMonitor.m` | SOURCE IMPLEMENTED, PARTIAL | Periodic added/removed class names; metadata changes not included |
| CSV/dependency export | `KARPAExporter.m` | SOURCE IMPLEMENTED, PARTIAL | CSV and image dependency JSON coded; no runtime test |
| ZIP export | `KARPAZipExporter.m` | SOURCE IMPLEMENTED | Stored ZIP writer coded; no device test |
| Collection history | `KARPAHistory.m` | SOURCE IMPLEMENTED | Append-only JSON history coded; no device test |
| UIKit interface/share sheet | `KARPAInterface.m` | SOURCE IMPLEMENTED, PARTIAL | Real buttons/actions coded; not compiled or presented on iOS |
| Diagnostics | `KARPADiagnostics.m` | SOURCE IMPLEMENTED, PARTIAL | OS/version/architecture/bundle/status fields coded; no device values verified |
| Build script | `build_ios.sh` | COMPILED | Builds Release arm64 on macOS, validates the product and packages the artifact |

## Local checks performed

Static source checks passed for the generated modules and integration references. The macOS workflow compiled all sources, linked the dylib, ran `validate_ios_binary.sh`, inspected the artifact contents and uploaded the result. Local Linux compilation remains unavailable.

## Required external validation

The workflow performed `file`, `otool -hv`, `otool -L` and symbol checks on the resulting arm64 `MH_DYLIB`. XCTest and authorized-device procedures in `TEST_PLAN.md` remain pending; only `COMPILED` has been promoted to verified.

No ESign compatibility claim is made. Any signing, loading or injection behavior depends on the authorized target, iOS version, code-signing state and the exact deployment workflow.

## Infrastructure added in the final-build pass

- `KARPA.xcodeproj/project.pbxproj`: target `KARPA` of type `com.apple.product-type.library.dynamic`, with `MACH_O_TYPE = mh_dylib`, Foundation, UIKit and all 16 existing `.m` files.
- `KARPA.xcconfig`: Release arm64 build, iOS 13.0, ARC and install name `@rpath/libKARPA.dylib`.
- `build_ios.sh`: deterministic macOS build, validation and packaging.
- `validate_ios_binary.sh`: `file`, `otool -hv`, `otool -L`, `nm` and arm64/MH_DYLIB assertions.
- `.github/workflows/ios-build.yml`: macOS runner, Release build, source-policy check and artifact upload.
- `INSTALL_AND_ESIGN.md`: signing guidance for an owned/authorized target and ESign limitations.

## Status of this revision

| Item | Status | Evidence |
|---|---|---|
| Existing source preserved | SOURCE IMPLEMENTED | No functional module was removed; the project references every `.m` file. |
| Complete Xcode project | COMPILED | Opened and built successfully by Xcode 16.4 on macOS. |
| macOS workflow | COMPILED | [Run 44623905776](https://github.com/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/actions/runs/44623905776) succeeded. |
| Local dylib compilation | NOT VERIFIED | Local Linux has no Apple toolchain; this is not a blocker for the remote build. |
| GitHub Actions compilation | COMPILED | Release arm64 build succeeded and uploaded artifact `14578915972`. |
| Mach-O, architecture, dependencies and exports | COMPILED | `MH_DYLIB`, arm64, expected system dependencies and KARPA exports validated. |
| JSON/CSV/ZIP/cancellation on device | NOT VERIFIED | Packaging passed; no XCTest/device is attached and collection remains synchronous. |
| ESign | NOT VERIFIED | The artifact is unsigned; signing and device validation remain required in an authorized environment. |

The primary compilation objective is complete. The remaining validation boundary is legitimate signing, loading and runtime behavior on an authorized iOS device; no device result is claimed.
