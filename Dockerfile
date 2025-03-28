FROM archlinux:multilib-devel

RUN pacman-key --init && pacman -Syu --noconfirm --needed base-devel git rust cargo
RUN useradd -m build && usermod -L build
RUN echo "build ALL=(ALL) NOPASSWD: /usr/bin/pacman #delete_me\
build ALL=(ALL) NOPASSWD: /usr/bin/yay #delete_me" > /etc/sudoers
RUN mkdir .paru && chown build:build .paru && su build -c "cd .paru && git clone https://aur.archlinux.org/paru . && makepkg -si --noconfirm"
RUN su build -c "paru --noconfirm -Syu ttf-dejavu aosp-devel"
RUN sed -i '/delete_me/d' /etc/sudoers
