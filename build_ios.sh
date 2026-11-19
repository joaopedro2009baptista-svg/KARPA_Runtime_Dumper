#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if command -v xcodebuild >/dev/null 2>&1; then
  if [ ! -d "$ROOT/KARPA.xcodeproj" ]; then
    echo "Xcode detected, but KARPA.xcodeproj is missing; create an iOS Dynamic Library target and add the source files." >&2
    exit 2
  fi
  xcodebuild -project "$ROOT/KARPA.xcodeproj" -scheme KARPA -configuration Release -sdk iphoneos build
  exit $?
fi
if [ -n "${THEOS:-}" ] && [ -x "${THEOS}/bin/clang" ]; then
  echo "Theos detected; no Makefile exists yet. Configure an authorized iOS dylib target before building." >&2
  exit 2
fi
echo "No Xcode/xcodebuild or usable Theos iOS SDK was found. No binary was produced." >&2
exit 3
