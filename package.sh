#!/bin/bash

# ==============================================================================
# Looper Player - Debian Packaging Script
# ==============================================================================
# This script bundles the Flutter Linux build into a .deb package.
# ==============================================================================

set -euo pipefail

# --- Configuration ---
APP_NAME="looper-player"
DISPLAY_NAME="Looper Player"
MAINTAINER="Nils Haaa <nilshaaa@example.com>"
DESCRIPTION="A modern high-fidelity music player for Linux."
CATEGORIES="AudioVideo;Audio;Music;Player;"
MIME_TYPES="audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;"

# --- Paths ---
BUILD_DIR="build/linux/x64/release/bundle"
OUTPUT_DIR="dist"
DEB_ROOT="$OUTPUT_DIR/deb_root"
ICON_SOURCE="assets/launcher_logo.png"

# --- Version Extraction ---
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
echo "🚀 Building $DISPLAY_NAME v$VERSION..."

# --- Validation ---
if [[ ! -d "$BUILD_DIR" ]]; then
    echo "❌ Error: Linux build not found in $BUILD_DIR"
    echo "Please run: flutter build linux --release"
    exit 1
fi

# Detect executable automatically
EXECUTABLE_NAME=$(find "$BUILD_DIR" -maxdepth 1 -type f -executable -not -name "*.so" | head -n 1)
if [[ -z "$EXECUTABLE_NAME" ]]; then
    echo "❌ Error: No executable found in $BUILD_DIR"
    exit 1
fi
EXECUTABLE_NAME=$(basename "$EXECUTABLE_NAME")
echo "🎯 Detected executable: $EXECUTABLE_NAME"

if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "⚠️ Warning: Icon not found at $ICON_SOURCE. Using default if available."
fi

# --- Cleanup & Setup ---
rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/DEBIAN"
mkdir -p "$DEB_ROOT/usr/bin"
mkdir -p "$DEB_ROOT/usr/lib/$APP_NAME"
mkdir -p "$DEB_ROOT/usr/share/applications"
mkdir -p "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps"

# --- Copy Build Files ---
echo "📦 Copying application files..."
cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"

# --- Install Icon ---
if [[ -f "$ICON_SOURCE" ]]; then
    cp "$ICON_SOURCE" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
fi

# --- Create Control File ---
cat <<EOF > "$DEB_ROOT/DEBIAN/control"
Package: $APP_NAME
Version: $VERSION
Section: sound
Priority: optional
Architecture: amd64
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Depends: libgtk-3-0, libmpv1 | libmpv2
EOF

# --- Create Launcher Script ---
cat <<EOF > "$DEB_ROOT/usr/bin/$APP_NAME"
#!/bin/bash
export GDK_BACKEND=wayland,x11
exec /usr/lib/$APP_NAME/$EXECUTABLE_NAME "\$@"
EOF
chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"

# --- Create Desktop Entry ---
cat <<EOF > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$DISPLAY_NAME
Comment=$DESCRIPTION
Exec=$APP_NAME %F
Icon=$APP_NAME
Terminal=false
StartupNotify=true
Categories=$CATEGORIES
MimeType=$MIME_TYPES
EOF

# --- Permissions Fix ---
find "$DEB_ROOT/usr" -type d -exec chmod 755 {} +
find "$DEB_ROOT/usr" -type f -exec chmod 644 {} +
chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"
chmod +x "$DEB_ROOT/usr/lib/$APP_NAME/$EXECUTABLE_NAME"

# --- Build Package ---
echo "🏗️  Constructing .deb package..."
dpkg-deb --build "$DEB_ROOT" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"

# --- Summary ---
echo "--------------------------------------------------"
echo "✅ Build Successful!"
echo "📦 Package: $OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
echo "--------------------------------------------------"
