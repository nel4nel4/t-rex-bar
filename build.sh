#!/bin/bash
# Builds T-Rex Bar.app into ./build
set -euo pipefail
cd "$(dirname "$0")"

APP="build/T-Rex Bar.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp Info.plist "$APP/Contents/Info.plist"

swiftc -O -o "$APP/Contents/MacOS/TRexBar" Sources/main.swift

# App icon: the binary renders its own 1024px art; scale the rest with sips.
ICONSET="build/icon.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET" "$APP/Contents/Resources"
"$APP/Contents/MacOS/TRexBar" --appicon "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  d=$((s * 2))
  sips -z $d $d "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

codesign --force --sign - "$APP" >/dev/null 2>&1 || true

echo "Built: $APP"
echo "Run:   open \"$APP\""
