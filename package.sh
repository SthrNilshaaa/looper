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
DEB_ROOT="$OUTPUT_DIR/deb_root_local"
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

# --- Build Debian Package ---
echo "🏗️  Constructing .deb package..."
DEB_FILE="$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
dpkg-deb --build "$DEB_ROOT" "$DEB_FILE"
echo "✅ Debian package constructed: $DEB_FILE"

# --- Build RPM Package ---
echo "🏗️  Constructing .rpm package from .deb..."
if command -v alien &> /dev/null && command -v fakeroot &> /dev/null; then
    # alien generates a package like: looper-player-1.5.1-2.x86_64.rpm or looper-player-1.5.1-1.x86_64.rpm
    # We use --keep-version to preserve the exact version.
    fakeroot alien --to-rpm --keep-version "$DEB_FILE"
    
    # alien builds the file in the current working directory, so find it and move it
    GENERATED_RPM=$(find . -maxdepth 1 -name "${APP_NAME}-*.rpm" | head -n 1)
    if [[ -n "$GENERATED_RPM" && -f "$GENERATED_RPM" ]]; then
        mv "$GENERATED_RPM" "$OUTPUT_DIR/"
        echo "✅ RPM package constructed: $OUTPUT_DIR/$(basename "$GENERATED_RPM")"
    else
        echo "⚠️  RPM package generated, but could not locate the file in the root directory."
    fi
else
    echo "⚠️  fakeroot or alien not installed. Skipping RPM generation."
fi

# --- Build Tarball Package ---
echo "🏗️  Constructing relocatable .tar.gz package..."
TAR_FILE="$OUTPUT_DIR/${APP_NAME}_${VERSION}_linux_x64.tar.gz"
TAR_STAGE="$OUTPUT_DIR/${APP_NAME}_${VERSION}_linux_x64"
rm -rf "$TAR_STAGE"
mkdir -p "$TAR_STAGE"
cp -r "$BUILD_DIR/"* "$TAR_STAGE/"
tar -czf "$TAR_FILE" -C "$OUTPUT_DIR" "$(basename "$TAR_STAGE")"
rm -rf "$TAR_STAGE"
echo "✅ Tarball package constructed: $TAR_FILE"

# --- Build AppImage ---
echo "🏗️  Constructing AppImage..."
APPDIR="$OUTPUT_DIR/AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/metainfo"

# Copy all bundle files to AppDir/usr/bin
cp -r "$BUILD_DIR/"* "$APPDIR/usr/bin/"

# Copy icon and symlink to root AppDir
if [[ -f "$ICON_SOURCE" ]]; then
    cp "$ICON_SOURCE" "$APPDIR/$APP_NAME.png"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    cp "$ICON_SOURCE" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
    ln -sf "$APP_NAME.png" "$APPDIR/.DirIcon"
fi

# Create launcher .desktop at AppDir root and usr/share/applications
cat <<EOF > "$APPDIR/$APP_NAME.desktop"
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

# Create the AppRun launcher at the root of AppDir
cat <<EOF > "$APPDIR/AppRun"
#!/bin/bash
SELF=\$(readlink -f "\$0")
HERE=\${SELF%/*}
export GDK_BACKEND=wayland,x11
export LD_LIBRARY_PATH="\$HERE/usr/bin:\$HERE/usr/bin/lib:\$LD_LIBRARY_PATH"
exec "\$HERE/usr/bin/$EXECUTABLE_NAME" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# Fix permissions
find "$APPDIR" -type d -exec chmod 755 {} +
find "$APPDIR" -type f -exec chmod 644 {} +
chmod +x "$APPDIR/AppRun"
chmod +x "$APPDIR/usr/bin/$EXECUTABLE_NAME"
if [[ -d "$APPDIR/usr/bin/lib" ]]; then
    find "$APPDIR/usr/bin/lib" -name "*.so*" -exec chmod +x {} +
fi

# Locate appimagetool
APPIMAGE_TOOL="/home/nilshaaa/Projects/one_player/.local/bin/appimagetool"
if [[ ! -x "$APPIMAGE_TOOL" ]]; then
    APPIMAGE_TOOL=$(which appimagetool || true)
fi

if [[ -n "$APPIMAGE_TOOL" && -x "$APPIMAGE_TOOL" ]]; then
    export ARCH=x86_64
    "$APPIMAGE_TOOL" "$APPDIR" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_x86_64.AppImage"
    echo "✅ AppImage package constructed: $OUTPUT_DIR/${APP_NAME}_${VERSION}_x86_64.AppImage"
else
    echo "⚠️  appimagetool not found or not executable. Skipping AppImage generation."
fi

# Cleanup
rm -rf "$APPDIR"
rm -rf "$DEB_ROOT"

# --- Summary ---
echo "--------------------------------------------------"
echo "✅ Build and Packaging Suite Execution Completed!"
echo "📦 Output Files in $OUTPUT_DIR/:"
ls -la "$OUTPUT_DIR"/*.{deb,rpm,tar.gz,AppImage} 2>/dev/null || ls -la "$OUTPUT_DIR"
echo "--------------------------------------------------"
