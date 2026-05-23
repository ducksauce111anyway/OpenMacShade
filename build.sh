#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ScreenShade"
BUNDLE_ID="local.screenshade"
MIN_MACOS_VERSION="15.0"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ARCHS=("x86_64" "arm64")

SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

rm -rf "$APP_DIR" "$BUILD_DIR/intermediates"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$BUILD_DIR/intermediates"

cp Resources/Info.plist "$CONTENTS_DIR/Info.plist"

for ARCH in "${ARCHS[@]}"; do
  TARGET="$ARCH-apple-macosx$MIN_MACOS_VERSION"
  ARCH_DIR="$BUILD_DIR/intermediates/$ARCH"
  mkdir -p "$ARCH_DIR"

  swiftc \
    -O \
    -target "$TARGET" \
    -sdk "$SDKROOT" \
    -parse-as-library \
    -emit-module \
    -emit-library \
    -static \
    -module-name ScreenShadeCore \
    -emit-module-path "$ARCH_DIR/ScreenShadeCore.swiftmodule" \
    Sources/ScreenShadeCore/ScreenShadeCore.swift \
    -o "$ARCH_DIR/libScreenShadeCore.a"

  swiftc \
    -O \
    -target "$TARGET" \
    -sdk "$SDKROOT" \
    -I "$ARCH_DIR" \
    -framework AppKit \
    Sources/main.swift \
    Sources/AppDelegate.swift \
    Sources/OverlayController.swift \
    Sources/StatusMenuController.swift \
    "$ARCH_DIR/libScreenShadeCore.a" \
    -o "$ARCH_DIR/$APP_NAME"
done

lipo -create \
  "$BUILD_DIR/intermediates/x86_64/$APP_NAME" \
  "$BUILD_DIR/intermediates/arm64/$APP_NAME" \
  -output "$MACOS_DIR/$APP_NAME"

INFO="$(lipo -info "$MACOS_DIR/$APP_NAME")"
echo "$INFO"

if [[ "$INFO" != *"x86_64"* || "$INFO" != *"arm64"* ]]; then
  echo "error: universal binary does not contain both x86_64 and arm64" >&2
  exit 1
fi

codesign --force --sign - --identifier "$BUNDLE_ID" "$APP_DIR"

echo "Built $APP_DIR"
