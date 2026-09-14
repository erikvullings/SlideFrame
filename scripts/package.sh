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
plutil -replace CFBundleExecutable -string SlideFrame "$APP/Contents/Info.plist"
chmod 755 "$APP/Contents/MacOS/SlideFrame"
codesign --force --sign - "$APP"

echo "Packaged $APP"
