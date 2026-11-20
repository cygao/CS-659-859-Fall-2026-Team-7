#!/bin/bash
# Create a local .app bundle for the SwiftUI feature preview.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This SwiftUI demo must be launched on a Mac."
    exit 1
fi

cd "$(dirname "$0")/.."
swift build --product FieldnoteDemo
BIN_DIR="$(swift build --show-bin-path)"
APP_DIR="$BIN_DIR/ResumeTune.app"
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$BIN_DIR/FieldnoteDemo" "$APP_DIR/Contents/MacOS/ResumeTune"
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>ResumeTune</string>
    <key>CFBundleIdentifier</key><string>edu.sfsu.csc659.team7.fieldnote.demo</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>ResumeTune</string>
    <key>CFBundleDisplayName</key><string>ResumeTune</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>0.1</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST
open "$APP_DIR"
echo "Opened $APP_DIR"
