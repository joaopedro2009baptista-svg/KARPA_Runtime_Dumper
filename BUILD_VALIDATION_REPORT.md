# KARPA — Build and compatibility report

## Environment inspected

The current execution environment is Linux ARM64. The following required Apple/iOS tools were not found: `xcodebuild`, `xcrun`, Apple `clang`, `ld64`, `ldid`, iOS SDK and Theos iOS SDK. `/usr/bin/make` exists but is not an iOS toolchain.

The project therefore has not produced an iOS Mach-O dynamic library in this environment. No Linux `.so`, simulator binary or renamed artifact is presented as an iOS DYLIB.

## Status categories

- **SOURCE IMPLEMENTED:** source module exists and is integrated into the collection/export path where stated.
- **COMPILED:** not verified; no Apple compiler/SDK is available here.
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
| Build script | `build_ios.sh` | SOURCE IMPLEMENTED | Correctly exits without build when Xcode/Theos is absent |

## Local checks performed

Static source checks passed for the generated modules and integration references. These checks are not a compiler test. The build script was executed and correctly reported that no Xcode/xcodebuild or usable Theos iOS SDK was available.

## Required external validation

On macOS with an appropriate Xcode/iOS SDK, create or complete an Xcode Dynamic Library target, add every `.m` file, build for an authorized app-owned test target, inspect the resulting Mach-O with `file`, `otool -hv`, `otool -L` and symbol tools, then execute the XCTest/device procedures in `TEST_PLAN.md`. Only after those steps may `COMPILED`, `UNIT TESTED` or `DEVICE TESTED` be changed from `NOT VERIFIED`.

No ESign compatibility claim is made. Any signing, loading or injection behavior depends on the authorized target, iOS version, code-signing state and the exact deployment workflow.
