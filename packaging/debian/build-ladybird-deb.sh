#!/bin/bash
set -e

# === 1. Variables ===
APP_NAME="ladybird"
VERSION="git$(date +%Y%m%d)"
ARCH="amd64"
BUILD_DIR="$HOME/debbuild"
INSTALL_DIR="$BUILD_DIR/${APP_NAME}_${VERSION}_${ARCH}"

# === 2. Prepare folders ===
rm -rf "$BUILD_DIR"
mkdir -p "$INSTALL_DIR/usr/local/bin"
mkdir -p "$INSTALL_DIR/usr/local/lib"
mkdir -p "$INSTALL_DIR/usr/share/applications"
mkdir -p "$INSTALL_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$INSTALL_DIR/DEBIAN"

# === 3. Copy binaries ===
cp "$HOME/ladybird-install/bin/Ladybird" "$INSTALL_DIR/usr/local/bin/ladybird"

# === 4. Copy runtime libraries (these are now required) ===
cp /usr/local/lib/lib*.so* "$INSTALL_DIR/usr/local/lib/"

# === 5. Desktop entry ===
cat > "$INSTALL_DIR/usr/share/applications/ladybird.desktop" <<EOF
[Desktop Entry]
Name=Ladybird Browser
Exec=/usr/local/bin/ladybird
Icon=ladybird
Type=Application
Categories=Network;WebBrowser;
EOF

# === 6. Icon ===
ICON_URL="https://raw.githubusercontent.com/LadybirdBrowser/ladybird/main/Meta/icons/256x256/app-ladybird.png"
wget -q -O "$INSTALL_DIR/usr/share/icons/hicolor/256x256/apps/ladybird.png" "$ICON_URL" || echo "⚠️ Could not fetch icon."

# === 7. DEBIAN control file ===
cat > "$INSTALL_DIR/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: web
Priority: optional
Architecture: $ARCH
Depends: libc6 (>= 2.31)
Maintainer: $(whoami)
Description: Ladybird Browser (Custom Git Build)
 Built from source with dynamic library support.
EOF

# === 8. Permissions ===
chmod 755 "$INSTALL_DIR/usr/local/bin/ladybird"
find "$INSTALL_DIR/DEBIAN" -type f -exec chmod 644 {} \;

# === 9. Build the package ===
dpkg-deb --build "$INSTALL_DIR"

echo "✅ .deb created:"
echo "$INSTALL_DIR.deb"
