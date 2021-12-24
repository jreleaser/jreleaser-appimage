#!/usr/bin/env bash

# Adapted from https://gist.github.com/neilcsmith-net/69bcb23bcc6698815438dc4e3df6caa3
# Original script: (c) 2020 Neil C Smith - neil@codelerity.com

shopt -s extglob

SYSTEM_ARCH="x86_64"
DISTRIBUTION_FILE="jreleaser-standalone-${DISTRIBUTION_VERSION}-linux-x86_64.zip"
DISTRIBUTION_FILE_NAME="jreleaser-standalone-${DISTRIBUTION_VERSION}-linux-x86_64"
DISTRIBUTION_EXEC="jreleaser"
DISTRIBUTION_URL="https://github.com/jreleaser/jreleaser/releases/download/v${DISTRIBUTION_VERSION}/${DISTRIBUTION_FILE}"
APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${SYSTEM_ARCH}.AppImage"

# create build directory for needed resources
mkdir -p build/
cd build/

# download AppImage tool
wget -c $APPIMAGETOOL_URL
chmod +x "./appimagetool-${SYSTEM_ARCH}.AppImage"

# download and extract Apache NetBeans release
wget -c -O $DISTRIBUTION_FILE $DISTRIBUTION_URL
unzip -o $DISTRIBUTION_FILE

# create AppDir structure
mkdir -p AppDir/
mkdir -p AppDir/usr/share/
mv "${DISTRIBUTION_FILE_NAME}/" AppDir/usr/share/${DISTRIBUTION_EXEC}
mkdir -p AppDir/usr/bin/
ln -s AppDir/usr/share/${DISTRIBUTION_FILE_NAME}/bin/${DISTRIBUTION_EXEC} AppDir/usr/bin/${DISTRIBUTION_EXEC}
mkdir -p AppDir/usr/share/applications/
mkdir -p AppDir/usr/share/icons/hicolor/128x128/
cp ../icons/${DISTRIBUTION_EXEC}.png AppDir/usr/share/icons/hicolor/128x128/${DISTRIBUTION_EXEC}.png
mkdir -p AppDir/usr/share/metainfo
cp ../org.jreleaser.cli.appdata.xml AppDir/usr/share/metainfo

cat > AppDir/usr/share/applications/${DISTRIBUTION_EXEC}.desktop <<EOF
[Desktop Entry]
Name=JReleaser
Exec=${DISTRIBUTION_EXEC}
Icon=${DISTRIBUTION_EXEC}
Categories=Development
Version=1.0
Type=Application
Terminal=true
EOF

ln -s usr/share/applications/${DISTRIBUTION_EXEC}.desktop AppDir/${DISTRIBUTION_EXEC}.desktop
ln -s usr/share/icons/hicolor/128x128/${DISTRIBUTION_EXEC}.png AppDir/${DISTRIBUTION_EXEC}.png
ln -s usr/share/icons/hicolor/128x128/${DISTRIBUTION_EXEC}.png AppDir/.DirIcon

# create AppRun script
cat > AppDir/AppRun << "EOF"
#!/usr/bin/env bash

HERE="$(dirname "$(readlink -f "${0}")")"

exec "$HERE/usr/share/jreleaser/bin/jreleaser" "$@"
EOF

chmod +x AppDir/AppRun

# build AppImage
ARCH=${SYSTEM_ARCH} "./appimagetool-${SYSTEM_ARCH}.AppImage" -v AppDir/ "../jreleaser-${DISTRIBUTION_VERSION}-${SYSTEM_ARCH}.AppImage"
