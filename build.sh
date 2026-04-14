#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Watti"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
BIN_DIR="$APP_DIR/Contents/MacOS"
RES_DIR="$APP_DIR/Contents/Resources"
SDKROOT="$(xcrun --show-sdk-path)"

rm -rf "$APP_DIR"
mkdir -p "$BIN_DIR" "$RES_DIR"

clang \
  -fobjc-arc \
  -mmacosx-version-min=13.0 \
  -isysroot "$SDKROOT" \
  -framework Cocoa \
  -framework IOKit \
  -framework QuartzCore \
  "$ROOT_DIR/Sources/Watti/main.m" \
  -o "$BIN_DIR/$APP_NAME"

cp "$ROOT_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

if [[ -f "$ROOT_DIR/Assets/Watti.icns" ]]; then
  cp "$ROOT_DIR/Assets/Watti.icns" "$RES_DIR/Watti.icns"
fi

echo "Built $APP_DIR"
