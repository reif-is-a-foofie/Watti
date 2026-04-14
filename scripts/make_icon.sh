#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ICONSET_DIR="$ROOT_DIR/Assets/Watti.iconset"
ICNS_PATH="$ROOT_DIR/Assets/Watti.icns"
SOURCE_PNG="$ROOT_DIR/Assets/Watti-icon-source.png"
RENDER_BIN="$ROOT_DIR/build/render_icon"
SDKROOT="$(xcrun --show-sdk-path)"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

function make_png_from_source() {
  local px="$1"
  local name="$2"
  local out="$ICONSET_DIR/$name"
  sips -Z "$px" "$SOURCE_PNG" --out "$out" >/dev/null
}

function make_png_from_renderer() {
  local px="$1"
  local name="$2"
  "$RENDER_BIN" "$px" "$ICONSET_DIR/$name"
}

function make_png() {
  local px="$1"
  local name="$2"
  if [[ -f "$SOURCE_PNG" ]]; then
    make_png_from_source "$px" "$name"
  else
    make_png_from_renderer "$px" "$name"
  fi
}

if [[ ! -f "$SOURCE_PNG" ]]; then
  mkdir -p "$ROOT_DIR/build"
  clang \
    -fobjc-arc \
    -mmacosx-version-min=13.0 \
    -isysroot "$SDKROOT" \
    -framework Cocoa \
    "$ROOT_DIR/scripts/render_icon.m" \
    -o "$RENDER_BIN"
fi

# Standard macOS iconset sizes
make_png 16   "icon_16x16.png"
make_png 32   "icon_16x16@2x.png"
make_png 32   "icon_32x32.png"
make_png 64   "icon_32x32@2x.png"
make_png 128  "icon_128x128.png"
make_png 256  "icon_128x128@2x.png"
make_png 256  "icon_256x256.png"
make_png 512  "icon_256x256@2x.png"
make_png 512  "icon_512x512.png"
make_png 1024 "icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"
echo "Wrote $ICNS_PATH"

