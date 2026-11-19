# KARPA Runtime Dumper — final build status

Date: 2026-11-19

## Result

The iOS ARM64 dynamic library was genuinely compiled by GitHub Actions on macOS and uploaded as an artifact. No device or ESign loading claim is made.

## Evidence

| Check | Status | Evidence |
|---|---|---|
| Existing source audit | SOURCE IMPLEMENTED | All existing Objective-C modules remain referenced by `KARPA.xcodeproj`. |
| Xcode project | COMPILED | Dynamic Library target, `mh_dylib`, iOS 13.0, arm64; build succeeded. |
| Local Linux build | NOT VERIFIED | Linux has no Xcode/iOS SDK; this is expected and did not fabricate a binary. |
| GitHub Actions workflow | COMPILED | [Run 44623905776](https://github.com/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/actions/runs/44623905776) — success. |
| Build and verification steps | PASS | `Build Release arm64 dylib`, `Verify source policy and artifact contents`, and artifact upload all succeeded. |
| Mach-O format | COMPILED / PASS | `Mach-O 64-bit arm64 dynamically linked shared library`; `MH_DYLIB`. |
| Dependencies | COMPILED / PASS | `CoreGraphics`, `Foundation`, `UIKit`, Objective-C runtime and system libraries; install name `@rpath/libKARPA.dylib`. |
| Exported symbols | COMPILED / PASS | KARPA collection, runtime inspection, diff, reports, CSV and ZIP entry points are present in `nm` output. |
| JSON/CSV/ZIP implementation | SOURCE IMPLEMENTED | Packaging and ZIP artifact validation passed; runtime report behavior was not exercised on an iOS device. |
| Unit tests | NOT VERIFIED | No XCTest suite was executed in this workflow. |
| Device test | NOT VERIFIED | No authorized iOS device was attached. |
| ESign compatibility | NOT VERIFIED | The artifact is unsigned and must be signed in the authorized host-app workflow. |

## Delivered artifact

Artifact name: `KARPA-iOS-arm64-f7ef6d62fe9b288dbde3418f394afc8f8148350f`

The artifact contains the real `libKARPA.dylib`, `xcodebuild.log`, `binary_validation.log`, `github-actions-build.log`, and `KARPA_iOS_arm64_artifacts.zip`. It was downloaded locally and independently identified as a Mach-O arm64 dylib.

## Repository state

Final commit: [`f7ef6d6`](https://github.com/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/commit/f7ef6d62fe9b288dbde3418f394afc8f8148350f)

The final artifact is available from the successful workflow run above through the GitHub Actions artifact download control. The artifact archive API URL is `https://api.github.com/repos/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/actions/artifacts/14578915972/zip` for an authenticated repository user.

## Honest compatibility boundary

The produced library is an unsigned build artifact, not an independently installable `.ipa`. For authorized testing, integrate it into an owned/test application and sign the complete application with the matching Team ID, entitlements and provisioning profile. ESign loading, device behavior, runtime report correctness and performance remain NOT VERIFIED until tested on an authorized iOS device.
