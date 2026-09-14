#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

APP="$ROOT/release/SlideFrame.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc \
    -parse-as-library \
    -O \
    -warnings-as-errors \
    -target arm64-apple-macosx14.0 \
    "$ROOT/SlideFrame/SlideFrameApp.swift" \
    "$ROOT/SlideFrame/AppState.swift" \
    "$ROOT/SlideFrame/GuideGeometry.swift" \
    "$ROOT/SlideFrame/Overlay/GuidePanel.swift" \
    "$ROOT/SlideFrame/Overlay/GuidePanelController.swift" \
    "$ROOT/SlideFrame/Overlay/GuideView.swift" \
    "$ROOT/SlideFrame/Menu/MenuBarContent.swift" \
    "$ROOT/SlideFrame/Persistence/FramePreferences.swift" \
    -o "$APP/Contents/MacOS/SlideFrame"
cp "$ROOT/SlideFrame/Info.plist" "$APP/Contents/Info.plist"
ICONSET="$ROOT/.build/AppIcon.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
SOURCE_ICON="$ROOT/SlideFrame/Assets.xcassets/AppIcon.appiconset/AppIcon1024.png"
for SPEC in "16:icon_16x16.png" "32:icon_16x16@2x.png" "32:icon_32x32.png" \
    "64:icon_32x32@2x.png" "128:icon_128x128.png" "256:icon_128x128@2x.png" \
    "256:icon_256x256.png" "512:icon_256x256@2x.png" "512:icon_512x512.png" \
    "1024:icon_512x512@2x.png"; do
    PIXELS=${SPEC%%:*}
    NAME=${SPEC#*:}
    sips -z "$PIXELS" "$PIXELS" "$SOURCE_ICON" --out "$ICONSET/$NAME" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
plutil -replace CFBundleExecutable -string SlideFrame "$APP/Contents/Info.plist"
chmod 755 "$APP/Contents/MacOS/SlideFrame"
codesign --force --sign - "$APP"

echo "Packaged $APP"
