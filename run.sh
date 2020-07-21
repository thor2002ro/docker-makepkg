#!/bin/bash

set -e

# Make a copy so we never alter the original
cp -r /pkg /tmp/pkg
cd /tmp/pkg

# Install (official repo + AUR) dependencies using yay. We avoid using makepkg
# -s since it is unable to install AUR dependencies.
raw_info="$(makepkg --printsrcinfo)"
printf "%s\n" "$raw_info" | grep -F depends | cut -f 2- -d '=' | sort -u > depends.txt
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
    sudo mv ./*pkg.tar* /pkg
fi
