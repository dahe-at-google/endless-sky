#!/bin/bash
set -e

# Builds Endless Sky and packages it as AppImage
# Control the output filename with the OUTPUT environment variable
# You may have to set the ARCH environment variable to e.g. x86_64.

# We need an icon file with a name matching the executable
cp icons/icon_512x512.png endless-sky.png

# Build
scons -Qj $(nproc) install DESTDIR=AppDir PREFIX=/usr

# Inside an AppImage, the executable is a link called "AppRun" at the root of AppDir/.
# Keeping the data files next to the executable is perfectly valid, so we just move them to AppDir/ to avoid errors.
mv AppDir/usr/share/games/endless-sky/* AppDir/

# Now build the actual AppImage
curl -sSL https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -o linuxdeploy && chmod +x linuxdeploy
OUTPUT=Endless_Sky-continuous-x86_64.AppImage ./linuxdeploy --appdir AppDir -e endless-sky -d endless-sky.desktop -i endless-sky.png --output appimage

# Use the static runtime for the AppImage. This lets the AppImage being run on systems without fuse2.
gh release download -R probonopd/go-appimage continuous -p appimagetool*x86_64.AppImage
mv ./appimagetool* appimagetool && chmod +x appimagetool

./Endless_Sky-continuous-x86_64.AppImage --appimage-extract
chmod -R 755 ./squashfs-root

if [ ! -z "$OUTPUT" ] ; then
  VERSION=000 ./appimagetool ./squashfs-root
  mv ./Endless_Sky-000-x86_64.AppImage $OUTPUT
else
  ./appimagetool ./squashfs-root
fi


# Clean up
rm -rf AppDir linuxdeploy appimagetool endless-sky.png Endless_Sky-continuous-x86_64.AppImage squashfs-root
