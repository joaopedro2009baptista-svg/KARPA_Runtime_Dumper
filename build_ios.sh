#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
DERIVED_DATA="$BUILD_DIR/DerivedData"
PRODUCT="$DERIVED_DATA/Build/Products/Release-iphoneos/libKARPA.dylib"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "No Xcode/xcodebuild or usable Theos iOS SDK was found. No binary was produced." >&2
  exit 3
fi
if [ ! -d "$ROOT/KARPA.xcodeproj" ]; then
  echo "KARPA.xcodeproj is missing." >&2
  exit 2
fi

mkdir -p "$BUILD_DIR"
	xcodebuild -project "$ROOT/KARPA.xcodeproj" -scheme KARPA -configuration Release \
	  -sdk iphoneos -derivedDataPath "$DERIVED_DATA" ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
	  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build \
  | tee "$BUILD_DIR/xcodebuild.log"

if [ ! -f "$PRODUCT" ]; then
  echo "Build completed without the expected product: $PRODUCT" >&2
  exit 4
fi

"$ROOT/validate_ios_binary.sh" "$PRODUCT" | tee "$BUILD_DIR/binary_validation.log"
mkdir -p "$BUILD_DIR/artifacts"
cp "$PRODUCT" "$BUILD_DIR/artifacts/libKARPA.dylib"
cp "$BUILD_DIR/xcodebuild.log" "$BUILD_DIR/artifacts/"
cp "$BUILD_DIR/binary_validation.log" "$BUILD_DIR/artifacts/"
(cd "$BUILD_DIR/artifacts" && zip -q -r ../KARPA_iOS_arm64_artifacts.zip .)
echo "Artifact: $BUILD_DIR/KARPA_iOS_arm64_artifacts.zip"
