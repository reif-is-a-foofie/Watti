#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/build/Watti.app"
OUT_DIR="$ROOT_DIR/build"
DMG_PATH="$OUT_DIR/Watti.dmg"
VOL_NAME="Watti"
STAGE_DIR="$OUT_DIR/dmg-stage"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing $APP_PATH (run ./build.sh first)" >&2
  exit 1
fi

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

cp -R "$APP_PATH" "$STAGE_DIR/"
ln -s /Applications "$STAGE_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create -volname "$VOL_NAME" -srcfolder "$STAGE_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null

echo "Built $DMG_PATH"
