#!/bin/bash

# Configuration
APP_NAME="one-player"
DISPLAY_NAME="OnePlayer"
VERSION="1.0.0"
MAINTAINER="Nils Haaa <nilshaaa@example.com>"
DESCRIPTION="A modern, high-fidelity music player for Linux."
CATEGORIES="AudioVideo;Audio;Music;Player;"

# Paths
BUILD_DIR="build/linux/x64/release/bundle"
OUTPUT_DIR="dist"
DEB_ROOT="dist/deb_root"
RPM_ROOT="dist/rpm_root"

# Ensure build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build not found. Please run 'flutter build linux --release' first."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# --- DEB Packaging ---
echo "📦 Building .deb package..."
mkdir -p "$DEB_ROOT/DEBIAN"
mkdir -p "$DEB_ROOT/usr/bin"
mkdir -p "$DEB_ROOT/usr/share/applications"
mkdir -p "$DEB_ROOT/usr/share/pixmaps"
mkdir -p "$DEB_ROOT/usr/lib/$APP_NAME"

# Copy Icon
if [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$DEB_ROOT/usr/share/pixmaps/$APP_NAME.png"
fi

# Create control file
cat <<EOF > "$DEB_ROOT/DEBIAN/control"
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

# Copy bundle
cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"

# Create launcher script
cat <<EOF > "$DEB_ROOT/usr/bin/$APP_NAME"
#!/bin/bash
/usr/lib/$APP_NAME/one_player "\$@"
EOF
chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"

# Create .desktop file
cat <<EOF > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop"
[Desktop Entry]
Version=$VERSION
Name=$DISPLAY_NAME
Comment=$DESCRIPTION
Exec=$APP_NAME %F
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=$CATEGORIES
MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
EOF

# Build DEB
dpkg-deb --build "$DEB_ROOT" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
echo "✅ DEB build complete: $OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"

# --- RPM Packaging ---
if command -v rpmbuild &> /dev/null; then
    echo "📦 Building native .rpm package using rpmbuild..."
    
    # Prepare rpmbuild directory
    RPM_TOPDIR="$HOME/rpmbuild"
    mkdir -p "$RPM_TOPDIR"/{SOURCES,SPECS,RPMS,BUILD,BUILDROOT}
    
    # Copy files to SOURCES
    cp -r "$BUILD_DIR" "$RPM_TOPDIR/SOURCES/bundle"
    if [ -f "assets/icon.png" ]; then
        cp "assets/icon.png" "$RPM_TOPDIR/SOURCES/icon.png"
    fi
    
    # Build RPM
    rpmbuild -bb --define "_topdir $RPM_TOPDIR" one-player.spec
    
    # Move result to dist
    cp "$RPM_TOPDIR"/RPMS/x86_64/${APP_NAME}-${VERSION}-*.rpm "$OUTPUT_DIR/"
    echo "✅ Native RPM build complete: $OUTPUT_DIR/"
elif command -v alien &> /dev/null; then
    echo "📦 Building .rpm package using alien (fallback)..."
    sudo alien -r "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
    mv *.rpm "$OUTPUT_DIR/" 2>/dev/null
    echo "✅ RPM build complete in $OUTPUT_DIR/"
else
    echo "⚠️ Packaging tools for RPM (rpmbuild/alien) not found. Please run: sudo apt install rpm"
fi

# Cleanup
# rm -rf "$DEB_ROOT"
