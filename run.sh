#!/bin/bash

set -e

SRC_DIR=$PWD

if [ -n "$1" ]
then
  SRC_DIR=$1
fi

if ! [ -e "$SRC_DIR/PKGBUILD" ]
then
  echo "source location $SRC_DIR not accessible."
  exit 1
fi

# Make a copy so we never alter the original
cp -rT "$SRC_DIR" /work
cd /work

# update mirrors
sudo reflector -p http,https -l 10 -f 4 --save /etc/pacman.d/mirrorlist

# Do the actual building
makepkg --noconfirm --syncdeps --force

# Store the built package(s). Ensure permissions match the original PKGBUILD.
if [ -n "$EXPORT_PKG" ]; then
    sudo chown "$(stat -c '%u:%g' /pkg/PKGBUILD)" ./*pkg.tar*
    sudo mv ./*pkg.tar* "$SRC_DIR"
fi
