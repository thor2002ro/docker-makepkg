FROM docker.io/archlinux/base

COPY run.sh /run.sh

# makepkg cannot (and should not) be run as root:
RUN useradd -m notroot

RUN pacman -Syu --noconfirm base-devel sudo reflector

RUN reflector -p http,https -l 10 -f 4 --save /etc/pacman.d/mirrorlist

COPY makepkg.conf /etc/makepkg.conf

# Allow notroot to run stuff as root (to install dependencies):
RUN echo "notroot ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/notroot

RUN mkdir /work && chown notroot /work

# Continue execution (and CMD) as notroot:
USER notroot
WORKDIR /home/notroot

# Auto-fetch GPG keys (for checking signatures):
RUN mkdir .gnupg && \
    chmod 0700 .gnupg && \
    touch .gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf

# Build the package
WORKDIR /pkg
CMD /bin/bash /run.sh
