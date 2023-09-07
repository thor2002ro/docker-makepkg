FROM docker.io/library/archlinux:base-devel

COPY run.sh /run.sh

# makepkg cannot (and should not) be run as root:
RUN useradd -m notroot

RUN pacman -Syu --noconfirm sudo reflector

RUN reflector -p http,https -l 10 -f 4 --save /etc/pacman.d/mirrorlist

RUN pacman -Syyuu --noconfirm

COPY makepkg.conf /etc/makepkg.conf

# Allow notroot to run stuff as root (to install dependencies):
RUN echo "notroot ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/notroot

RUN mkdir /tmp/work && chown notroot /tmp/work

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
