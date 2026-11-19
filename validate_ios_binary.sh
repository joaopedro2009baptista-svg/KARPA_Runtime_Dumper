#!/bin/sh
set -eu
BIN="${1:-}"
if [ -z "$BIN" ] || [ ! -f "$BIN" ]; then
  echo "Usage: $0 /path/to/libKARPA.dylib" >&2
  exit 2
fi
command -v file >/dev/null 2>&1 || { echo "file is required" >&2; exit 2; }
command -v otool >/dev/null 2>&1 || { echo "otool is required (macOS/Xcode Command Line Tools)" >&2; exit 2; }
command -v nm >/dev/null 2>&1 || { echo "nm is required" >&2; exit 2; }

echo "== file =="
file "$BIN"
echo "== Mach-O header =="
otool -hv "$BIN"
echo "== dependencies =="
otool -L "$BIN"
echo "== exported KARPA symbols =="
nm -gU "$BIN" | grep -E 'KARPA|_OBJC_CLASS_\$_KARPA' || true

echo "== assertions =="
file "$BIN" | grep -E 'Mach-O.*dynamically linked shared library.*arm64' >/dev/null
otool -hv "$BIN" | grep -E 'MH_DYLIB' >/dev/null
echo "VALIDATION_STATUS=PASS"
