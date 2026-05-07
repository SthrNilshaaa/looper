#!/bin/bash

# Configuration
APP_NAME="looper_player"
DISPLAY_NAME="Looper Player"
VERSION="1.0.0"
MAINTAINER="Nils Haaa <nilshaaa@example.com>"
DESCRIPTION="A modern, high-fidelity music player for Linux."
CATEGORIES="AudioVideo;Audio;Music;Player;"

# Paths
BUILD_DIR="build/linux/x64/release/bundle"
OUTPUT_DIR="dist"
DEB_ROOT="dist/deb_root"

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
    if [ -f "assets/launcher_logo.png" ]; then
        cp "assets/launcher_logo.png" "$DEB_ROOT/usr/share/pixmaps/$APP_NAME.png"
    fi

# Create control file
cat <<EOF > "$DEB_ROOT/DEBIAN/control"
Package: ${APP_NAME//_/-}
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Depends: libgtk-3-0, libmpv1 | libmpv2
EOF

# Copy bundle
cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"

# Create launcher script (with Wayland fix)
cat <<EOF > "$DEB_ROOT/usr/bin/$APP_NAME"
#!/bin/bash
# Force native Wayland backend on systems that support it
export GDK_BACKEND=wayland,x11
/usr/lib/$APP_NAME/looper_player "\$@"
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

    # Create the .spec file with Fedora/RPM dependencies
    cat <<EOF > "$RPM_TOPDIR/SPECS/$APP_NAME.spec"
Name:           ${APP_NAME//_/-}
Version:        $VERSION
Release:        1%{?dist}
Summary:        $DESCRIPTION
License:        MIT
BuildArch:      x86_64
# Essential rendering and audio dependencies for Fedora
Requires:       gtk3, mpv-libs, vlc-libs, libappindicator-gtk3

%description
$DESCRIPTION

%install
mkdir -p %{buildroot}/usr/lib/%{name}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/pixmaps

# Copy files using absolute paths from the project directory
cp -r $(pwd)/$BUILD_DIR/* %{buildroot}/usr/lib/%{name}/
if [ -f "$(pwd)/assets/Logo_launcher.png" ]; then
    cp $(pwd)/assets/Logo_launcher.png %{buildroot}/usr/share/pixmaps/%{name}.png
fi

# Create launcher with Wayland environment fix
cat <<BIN > %{buildroot}/usr/bin/%{name}
#!/bin/bash
export GDK_BACKEND=wayland,x11
/usr/lib/%{name}/looper_player "\\\$@"
BIN
chmod +x %{buildroot}/usr/bin/%{name}

# Create desktop file
cat <<DESK > %{buildroot}/usr/share/applications/%{name}.desktop
[Desktop Entry]
Version=$VERSION
Name=$DISPLAY_NAME
Comment=$DESCRIPTION
Exec=%{name} %F
Icon=%{name}
Terminal=false
Type=Application
Categories=$CATEGORIES
MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
DESK

%files
/usr/bin/%{name}
/usr/lib/%{name}/
/usr/share/applications/%{name}.desktop
/usr/share/pixmaps/%{name}.png

%changelog
* $(date +"%a %b %d %Y") $MAINTAINER - $VERSION
- Improved Wayland support and added system dependencies
EOF

    # Build RPM
    rpmbuild -bb "$RPM_TOPDIR/SPECS/$APP_NAME.spec"

    # Move result to dist
    cp "$RPM_TOPDIR"/RPMS/x86_64/${APP_NAME}-${VERSION}-*.rpm "$OUTPUT_DIR/"
    echo "✅ Native RPM build complete in $OUTPUT_DIR/"

elif command -v alien &> /dev/null; then
    echo "📦 Building .rpm package using alien (fallback)..."
    sudo alien -r "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
    mv *.rpm "$OUTPUT_DIR/" 2>/dev/null
    echo "✅ RPM build complete (via alien) in $OUTPUT_DIR/"
else
    echo "⚠️ Packaging tools not found."
fi

# # --- AppImage Packaging ---
# echo "📦 Building universal .AppImage..."

# # 1. Download appimagetool if not present or if it's invalid
# if [ ! -f "appimagetool" ] || ! grep -q "ELF" "appimagetool" 2>/dev/null; then
#     echo "Downloading appimagetool..."
#     rm -f appimagetool
#     wget -q https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage -O appimagetool
#     chmod +x appimagetool
# fi

# # 2. Prepare AppDir structure
# rm -rf "$APPIMAGE_ROOT"
# mkdir -p "$APPIMAGE_ROOT/usr/bin"
# mkdir -p "$APPIMAGE_ROOT/usr/lib"
# mkdir -p "$APPIMAGE_ROOT/usr/share/applications"
# mkdir -p "$APPIMAGE_ROOT/usr/share/icons/hicolor/256x256/apps"

# # 3. Copy Flutter bundle
# cp -r "$BUILD_DIR/"* "$APPIMAGE_ROOT/usr/lib/"

# # 4. Create AppRun (The entry point)
# cat <<EOF > "$APPIMAGE_ROOT/AppRun"
# #!/bin/bash
# HERE="\$(dirname "\$(readlink -f "\${0}")")"
# export LD_LIBRARY_PATH="\$HERE/usr/lib/lib:\$LD_LIBRARY_PATH"
# export GDK_BACKEND=wayland,x11
# "\$HERE/usr/lib/looper_player" "\$@"
# EOF
# chmod +x "$APPIMAGE_ROOT/AppRun"

# # 5. Create .desktop file and Icon for AppImage
# cat <<EOF > "$APPIMAGE_ROOT/$APP_NAME.desktop"
# [Desktop Entry]
# Type=Application
# Name=$DISPLAY_NAME
# Exec=$APP_NAME
# Icon=$APP_NAME
# Categories=$CATEGORIES
# EOF

if [ -f "assets/launcher_logo.png" ]; then
    cp "assets/launcher_logo.png" "$APPIMAGE_ROOT/$APP_NAME.png"
    cp "assets/launcher_logo.png" "$APPIMAGE_ROOT/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
fi

# 6. Build the final AppImage
# Note: ARCH=x86_64 is required by appimagetool
ARCH=x86_64 ./appimagetool "$APPIMAGE_ROOT" "$OUTPUT_DIR/$DISPLAY_NAME-$VERSION-x86_64.AppImage"

echo "✅ AppImage build complete: $OUTPUT_DIR/$DISPLAY_NAME-$VERSION-x86_64.AppImage"

# Cleanup
rm -rf "$DEB_ROOT"
rm -rf "$APPIMAGE_ROOT"
echo "🚀 All packages (DEB, RPM, AppImage) are ready in $OUTPUT_DIR/"

# Cleanup
rm -rf "$DEB_ROOT"
echo "🚀 All packaging tasks finished."

##!/bin/bash
#
## Configuration
#APP_NAME="looper-player"
#DISPLAY_NAME="Looper Player"
#VERSION="1.0.0"
#MAINTAINER="Nils Haaa <nilshaaa@example.com>"
#DESCRIPTION="A modern, high-fidelity music player for Linux."
#CATEGORIES="AudioVideo;Audio;Music;Player;"
#
## Paths
#BUILD_DIR="build/linux/x64/release/bundle"
#OUTPUT_DIR="dist"
#DEB_ROOT="dist/deb_root"
#
## Ensure build exists
#if [ ! -d "$BUILD_DIR" ]; then
#    echo "Error: Build not found. Please run 'flutter build linux --release' first."
#    exit 1
#fi
#
#mkdir -p "$OUTPUT_DIR"
#
## --- DEB Packaging ---
#echo "📦 Building .deb package..."
#mkdir -p "$DEB_ROOT/DEBIAN"
#mkdir -p "$DEB_ROOT/usr/bin"
#mkdir -p "$DEB_ROOT/usr/share/applications"
#mkdir -p "$DEB_ROOT/usr/share/pixmaps"
#mkdir -p "$DEB_ROOT/usr/lib/$APP_NAME"
#
## Copy Icon
#if [ -f "assets/logo_linux.png" ]; then
#    cp "assets/logo_linux.png" "$DEB_ROOT/usr/share/pixmaps/$APP_NAME.png"
#fi
#
## Create control file
#cat <<EOF > "$DEB_ROOT/DEBIAN/control"
#Package: $APP_NAME
#Version: $VERSION
#Section: utils
#Priority: optional
#Architecture: amd64
#Maintainer: $MAINTAINER
#Description: $DESCRIPTION
#EOF
#
## Copy bundle
#cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"
#
## Create launcher script
#cat <<EOF > "$DEB_ROOT/usr/bin/$APP_NAME"
##!/bin/bash
#/usr/lib/$APP_NAME/looper_player "\$@"
#EOF
#chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"
#
## Create .desktop file
#cat <<EOF > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop"
#[Desktop Entry]
#Version=$VERSION
#Name=$DISPLAY_NAME
#Comment=$DESCRIPTION
#Exec=$APP_NAME %F
#Icon=$APP_NAME
#Terminal=false
#Type=Application
#Categories=$CATEGORIES
#MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
#EOF
#
## Build DEB
#dpkg-deb --build "$DEB_ROOT" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
#echo "✅ DEB build complete: $OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
#
## --- RPM Packaging ---
#if command -v rpmbuild &> /dev/null; then
#    echo "📦 Building native .rpm package using rpmbuild..."
#
#    # Prepare rpmbuild directory
#    RPM_TOPDIR="$HOME/rpmbuild"
#    mkdir -p "$RPM_TOPDIR"/{SOURCES,SPECS,RPMS,BUILD,BUILDROOT}
#
#    # Create the .spec file
#    cat <<EOF > "$RPM_TOPDIR/SPECS/$APP_NAME.spec"
#Name:           $APP_NAME
#Version:        $VERSION
#Release:        1%{?dist}
#Summary:        $DESCRIPTION
#License:        MIT
#BuildArch:      x86_64
#
#%description
#$DESCRIPTION
#
#%install
#mkdir -p %{buildroot}/usr/lib/%{name}
#mkdir -p %{buildroot}/usr/bin
#mkdir -p %{buildroot}/usr/share/applications
#mkdir -p %{buildroot}/usr/share/pixmaps
#
## Copy files using absolute paths from the project directory
#cp -r $(pwd)/$BUILD_DIR/* %{buildroot}/usr/lib/%{name}/
#if [ -f "$(pwd)/assets/logo_linux.png" ]; then
#    cp $(pwd)/assets/logo_linux.png %{buildroot}/usr/share/pixmaps/%{name}.png
#fi
#
## Create launcher
#cat <<BIN > %{buildroot}/usr/bin/%{name}
##!/bin/bash
#/usr/lib/%{name}/looper_player "\\\$@"
#BIN
#chmod +x %{buildroot}/usr/bin/%{name}
#
## Create desktop file
#cat <<DESK > %{buildroot}/usr/share/applications/%{name}.desktop
#[Desktop Entry]
#Version=$VERSION
#Name=$DISPLAY_NAME
#Comment=$DESCRIPTION
#Exec=%{name} %F
#Icon=%{name}
#Terminal=false
#Type=Application
#Categories=$CATEGORIES
#MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
#DESK
#
#%files
#/usr/bin/%{name}
#/usr/lib/%{name}/
#/usr/share/applications/%{name}.desktop
#/usr/share/pixmaps/%{name}.png
#
#%changelog
#* $(date +"%a %b %d %Y") $MAINTAINER - $VERSION
#- Initial RPM release
#EOF
#
#    # Build RPM
#    rpmbuild -bb "$RPM_TOPDIR/SPECS/$APP_NAME.spec"
#
#    # Move result to dist
#    cp "$RPM_TOPDIR"/RPMS/x86_64/${APP_NAME}-${VERSION}-*.rpm "$OUTPUT_DIR/"
#    echo "✅ Native RPM build complete in $OUTPUT_DIR/"
#
#elif command -v alien &> /dev/null; then
#    echo "📦 Building .rpm package using alien (fallback)..."
#    sudo alien -r "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
#    mv *.rpm "$OUTPUT_DIR/" 2>/dev/null
#    echo "✅ RPM build complete (via alien) in $OUTPUT_DIR/"
#else
#    echo "⚠️ rpmbuild not found. Install it with 'sudo apt install rpm' or 'sudo dnf install rpm-build'."
#fi
#
## Cleanup
#rm -rf "$DEB_ROOT"
#echo "🚀 All packaging tasks finished."
##
### Configuration
##APP_NAME="looper-player"
##DISPLAY_NAME="Looper Player"
##VERSION="1.0.0"
##MAINTAINER="Nils Haaa <nilshaaa@example.com>"
##DESCRIPTION="A modern, high-fidelity music player for Linux."
##CATEGORIES="AudioVideo;Audio;Music;Player;"
##
### Paths
##BUILD_DIR="build/linux/x64/release/bundle"
##OUTPUT_DIR="dist"
##DEB_ROOT="dist/deb_root"
##RPM_ROOT="dist/rpm_root"
##
### Ensure build exists
##if [ ! -d "$BUILD_DIR" ]; then
##    echo "Error: Build not found. Please run 'flutter build linux --release' first."
##    exit 1
##fi
##
##mkdir -p "$OUTPUT_DIR"
##
### --- DEB Packaging ---
##echo "📦 Building .deb package..."
##mkdir -p "$DEB_ROOT/DEBIAN"
##mkdir -p "$DEB_ROOT/usr/bin"
##mkdir -p "$DEB_ROOT/usr/share/applications"
##mkdir -p "$DEB_ROOT/usr/share/pixmaps"
##mkdir -p "$DEB_ROOT/usr/lib/$APP_NAME"
##
### Copy Icon
##if [ -f "assets/logo_linux.png" ]; then
##    cp "assets/logo_linux.png" "$DEB_ROOT/usr/share/pixmaps/$APP_NAME.png"
##fi
##
### Create control file
##cat <<EOF > "$DEB_ROOT/DEBIAN/control"
##Package: $APP_NAME
##Version: $VERSION
##Section: utils
##Priority: optional
##Architecture: amd64
##Maintainer: $MAINTAINER
##Description: $DESCRIPTION
##EOF
##
### Copy bundle
##cp -r "$BUILD_DIR/"* "$DEB_ROOT/usr/lib/$APP_NAME/"
##c
### Create launcher script
##cat <<EOF > "$DEB_ROOT/usr/bin/$APP_NAME"
###!/bin/bash
##/usr/lib/$APP_NAME/looper_player "\$@"
##EOF
##chmod +x "$DEB_ROOT/usr/bin/$APP_NAME"
##
### Create .desktop file
##cat <<EOF > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop"
##[Desktop Entry]
##Version=$VERSION
##Name=$DISPLAY_NAME
##Comment=$DESCRIPTION
##Exec=$APP_NAME %F
##Icon=$APP_NAME
##Terminal=false
##Type=Application
##Categories=$CATEGORIES
##MimeType=audio/mpeg;audio/ogg;audio/x-wav;audio/flac;audio/mp4;audio/x-mp3;audio/x-m4a;
##EOF
##
### Build DEB
##dpkg-deb --build "$DEB_ROOT" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
##echo "✅ DEB build complete: $OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
##
### --- RPM Packaging ---
##if command -v rpmbuild &> /dev/null; then
##    echo "📦 Building native .rpm package using rpmbuild..."
##
##    # Prepare rpmbuild directory
##    RPM_TOPDIR="$HOME/rpmbuild"
##    mkdir -p "$RPM_TOPDIR"/{SOURCES,SPECS,RPMS,BUILD,BUILDROOT}
##
##    # Copy files to SOURCES
##    cp -r "$BUILD_DIR" "$RPM_TOPDIR/SOURCES/bundle"
##    if [ -f "assets/Logo_launcher.png" ]; then
##        cp "assets/Logo_launcher.png" "$RPM_TOPDIR/SOURCES/icon.png"
##    fi
##
##    # Update AppImageTool download
##    if [ ! -f "appimagetool" ]; then
##        wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
##        chmod +x appimagetool
##    fi
##
##    rpmbuild -bb --define "_topdir $RPM_TOPDIR" looper-player.spec
##
##    # Move result to dist
##    cp "$RPM_TOPDIR"/RPMS/x86_64/${APP_NAME//_/-}-${VERSION}-*.rpm "$OUTPUT_DIR/"
##    echo "✅ Native RPM build complete: $OUTPUT_DIR/"
##elif command -v alien &> /dev/null; then
##    echo "📦 Building .rpm package using alien (fallback)..."
##    sudo alien -r "$OUTPUT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
##    mv *.rpm "$OUTPUT_DIR/" 2>/dev/null
##    echo "✅ RPM build complete in $OUTPUT_DIR/"
##else
##    echo "⚠️ Packaging tools for RPM (rpmbuild/alien) not found. Please run: sudo apt install rpm"
##fi
##
### Cleanup
### rm -rf "$DEB_ROOT"
