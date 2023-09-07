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
cp -rT "$SRC_DIR" /tmp/work
cd /tmp/work

# update mirrors
sudo reflector --verbose --protocol http,https --age 6 --latest 10 --fastest 4 --save /etc/pacman.d/mirrorlist

# update packages
sudo pacman -Syyuu --noconfirm

# Do the actual building
makepkg --noconfirm --syncdeps --force

# Store the built package(s). Ensure permissions match the original PKGBUILD.
if [ -n "$EXPORT_PKG" ]; then
    sudo chown "$(stat -c '%u:%g' /pkg/PKGBUILD)" ./*pkg.tar*
    sudo mv ./*pkg.tar* "$SRC_DIR"
fi
