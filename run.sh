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
cp -r "$SRC_DIR" /tmp/pkg
cd /tmp/pkg

# Install (official repo + AUR) dependencies using yay. We avoid using makepkg
# -s since it is unable to install AUR dependencies.
raw_info="$(makepkg --printsrcinfo)"
printf "%s\n" "$raw_info" | grep -F depends | cut -f 2- -d '=' | cut -f 1 -d ":" | sort -u > depends.txt
printf "%s\n" "$raw_info" | grep -F pkgname | cut -f 2- -d '=' | sort    > pgkname.txt
deps="$(comm -23 depends.txt pgkname.txt)"

# here we want word splitting
# shellcheck disable=SC2046,SC2086
yay -Sy --noconfirm $(pacman --deptest $deps)

# Do the actual building
makepkg -f

# Store the built package(s). Ensure permissions match the original PKGBUILD.
if [ -n "$EXPORT_PKG" ]; then
    sudo chown "$(stat -c '%u:%g' /pkg/PKGBUILD)" ./*pkg.tar*
    sudo mv ./*pkg.tar* "$SRC_DIR"
fi
