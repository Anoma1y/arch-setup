#!/bin/bash

set -e

function base_install() {
    pacman_install "
        nano \
        git \
        bind \
        cmake \
        dmidecode \
        lsof \
        ntp \
        openssh \
        traceroute \
        net-tools \
        tree \
        ufw \
        wget \
        curl \
        rsync \
        fastfetch \
        ncdu \
        man-db \
        man-pages
    "
    pacman_install "ffmpeg"
    pacman_install "
        unzip \
        unrar \
        zip \
        p7zip
    "
}

function xorg_install() {
    info "Installing XORG packages..."

    pacman_install "
        xorg \
        xorg-apps \
        xorg-drivers \
        xorg-server \
        xorg-xinit \
        xorg-xkill \
        xorg-xrandr
    "
}

function audio_install() {
    info "Installing audio drivers and utils..."

    pacman_uninstall "jack2"
    pacman_install "
        pipewire-alsa \
        pipewire-jack \
        pipewire-pulse \
        lib32-pipewire \
        lib32-pipewire-jack \
        wireplumber \
        alsa-plugins \
        alsa-utils \
        pavucontrol
    "
}

function fonts_install() {
    info "Installing fonts..."

    pacman_install "
        powerline-fonts \
        terminus-font \
        ttf-droid \
        ttf-firacode-nerd \
        ttf-fira-code \
        ttf-liberation \
        ttf-roboto \
        ttf-jetbrains-mono \
        ttf-font-awesome
    "
    aur_install "noto-fonts-emoji"
}

function additional_install() {
    info "Installing bluetooth drivers and utils..."
    pacman_install "
        bluez \
        bluez-utils \
        blueberry
    "

    info "Installing printer drivers and utils..."
    pacman_install "
        cups \
        cups-pdf \
        ghostscript \
        system-config-printer
    "

    info "Installing USB drivers and utils..."
    pacman_install "usbutils"
}

function gui_install() {
    info "Installing GUI applications..."

    pacman_install "
        telegram-desktop \
        discord \
        mpv \
        flameshot \
        gnome-calculator \
        dunst \
        filezilla \
        firefox \
        obs-studio \
        libreoffice-still
    "
    aur_install "google-chrome"
}

function develop_install() {
    info "Installing develop utils..."

    pacman_install "
        python \
        go \
        docker \
        docker-compose \
        nodejs
    "
}

function main() {
    base_install
    xorg_install
    audio_install
    fonts_install
    additional_install
    gui_install
    develop_install
}

main
