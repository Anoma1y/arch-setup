#!/bin/bash

set -e

function base_install() {
    local packages=(
        "nano"
        "vim"
        "git"
        "bind"
        "cmake"
        "dmidecode"
        "lsof"
        "ntp"
        "openssh"
        "traceroute"
        "net-tools"
        "tree"
        "ufw"
        "yq"
        "wget"
        "curl"
        "rsync"
        "fastfetch"
        "ncdu"
        "man-db"
        "man-pages"
        "ranger"
        "ffmpeg"
        "unzip"
        "unrar"
        "zip"
        "p7zip"
    )

    pacman_install "${packages[@]}"
}

function xorg_install() {
    info "Installing XORG packages..."

    local packages=(
        "xorg"
        "xorg-apps"
        "xorg-xauth"
        "xorg-drivers"
        "xorg-server"
        "xorg-xinit"
        "xorg-xkill"
        "xorg-xrandr"
    )

    pacman_install "${packages[@]}"
}

function audio_install() {
    info "Installing audio drivers and utils..."

    local redundant_packages=("jack2")
    local packages=(
        "pipewire-alsa"
        "pipewire-jack"
        "pipewire-pulse"
        "lib32-pipewire"
        "lib32-pipewire-jack"
        "wireplumber"
        "alsa-plugins"
        "alsa-utils"
        "pavucontrol"
    )

    pacman_uninstall "${redundant_packages[@]}"
    pacman_install "${packages[@]}"
}

function fonts_install() {
    info "Installing fonts..."

    local packages=(
        "powerline-fonts"
        "terminus-font"
        "ttf-droid"
        "ttf-firacode-nerd"
        "ttf-fira-code"
        "ttf-liberation"
        "ttf-roboto"
        "ttf-jetbrains-mono"
        "ttf-font-awesome"
    )
    local aur_packages=("noto-fonts-emoji")

    pacman_install "${packages[@]}"
    aur_install "${aur_packages[@]}"
}

function additional_install() {
    info "Installing additional packages..."

    local bluetooth_packages=(
        "bluez"
        "bluez-utils"
        "blueberry"
    )
    local printer_packages=(
        "cups"
        "cups-pdf"
        "ghostscript"
        "system-config-printer"
    )
    local usb_packages=(
        "usbutils"
    )

    info_sub "Installing bluetooth drivers and utils..."
    pacman_install "${bluetooth_packages[@]}"

    info_sub "Installing printer drivers and utils..."
    pacman_install "${printer_packages[@]}"

    info_sub "Installing USB drivers and utils..."
    pacman_install "${usb_packages[@]}"

}

function gui_install() {
    info "Installing GUI applications..."

    local packages=(
        "telegram-desktop"
        "discord"
        "mpv"
        "flameshot"
        "gnome-calculator"
        "dunst"
        "filezilla"
        "firefox"
        "obs-studio"
        "libreoffice-still"
    )
    local aur_packages=(
        "google-chrome"
    )

    pacman_install "${packages[@]}"
    aur_install "${aur_packages[@]}"
}

function develop_install() {
    info "Installing develop utils..."

    local packages=(
        "python"
        "go"
        "docker"
        "docker-compose"
        "nodejs"
    )

    pacman_install "${packages[@]}"
}

function main() {
    base_install
    fonts_install

    if [[ "$DEVICE" != "server" ]]; then
        audio_install
        xorg_install
        gui_install
        additional_install
    fi

    develop_install
}

main
