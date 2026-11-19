# KARPA Runtime Dumper — final build status

Date: 2026-11-19

## Result

No compiled iOS `.dylib` is attached to this revision. No binary was fabricated.

## Evidence

| Check | Status | Evidence |
|---|---|---|
| Existing source audit | SOURCE IMPLEMENTED | All existing `.m` modules remain referenced by `KARPA.xcodeproj`. |
| Xcode project | CONFIGURED | Dynamic Library target, `mh_dylib`, Foundation/UIKit, iOS 13.0, arm64. |
| Local Linux build | NOT VERIFIED | `./build_ios.sh` returned exit 3: `No Xcode/xcodebuild or usable Theos iOS SDK was found. No binary was produced.` |
| Static project checks | PASS | 16 Objective-C sources referenced, no duplicate PBX UUIDs, shell syntax valid, `git diff --check` passed. |
| GitHub Actions attempt 1 | BLOCKED | [Run 44615612757](https://github.com/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/actions/runs/44615612757) was cancelled before steps; job had `runner_id: 0` and no steps. |
| GitHub Actions attempt 2 | BLOCKED | [Run 44615733068](https://github.com/joaopedro2009baptista-svg/KARPA_Runtime_Dumper/actions/runs/44615733068) remained queued with no `runner_id` after more than one minute. |
| Mach-O verification | NOT VERIFIED | Requires a produced iOS Mach-O. |
| JSON/CSV/ZIP runtime validation | NOT VERIFIED | Requires compiled execution in an authorized iOS host/device. |
| Device/ESign compatibility | NOT VERIFIED | Requires legitimate signing and an authorized device. |

## Exact remaining blocker

The current Linux sandbox cannot provide Apple's Xcode/iOS SDK. The repository is configured to use GitHub Actions `macos-13`, but this private repository/account did not allocate a macOS runner: one run was cancelled immediately and the next stayed queued with no runner assigned. Enable macOS Actions minutes/billing or run the workflow on an authorized Mac, then download the generated artifact from the successful run.
