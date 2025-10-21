#!/bin/bash

set -e

function base_install() {
    local packages=(
        "nano"
        "neovim"
        "git"
        "git-lfs"
        "bind"
        "cmake"
        "bat"
        "eza"
        "zoxide"
        "dmidecode"
        "lsof"
        "ntp"
        "openssh"
        "openconnect"
        "traceroute"
        "mdadm"
        "samba"
        "tmux"
        "net-tools"
        "tree"
        "ufw"
        "yq"
        "wget"
        "curl"
        "rsync"
        "feh"
        "fastfetch"
        "ncdu"
        "man-db"
        "man-pages"
        "ranger"
        "fuse"
        "playerctl"
#        "w3m" # required by "ranger"
        "ueberzugpp" # required by "ranger"
		"keepass"
        "ffmpeg"
        "imagemagick"
        "unzip"
        "unrar"
        "zip"
        "p7zip"
        "img2pdf"
        "gvfs-smb"
    )

    pacman_install "${packages[@]}"
}

function i3_install() {
    info "Installing I3 packages..."

    local packages=(
        "i3-wm"
        "polybar"
        "rofi"
        "xss-lock"
        "i3lock"
        "dunst"
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
        "gtk3"
        "telegram-desktop"
        "mpv"
        "gpicview"
        "flameshot"
        "gnome-calculator"
        "dunst"
        "filezilla"
        "firefox"
        "obs-studio"
        "nemo"
        "nemo-fileroller"
        "libreoffice-still"
    )
    local packages_zathura=(
        "zathura"
        "zathura-pdf-mupdf"
        "zathura-djvu"
        "zathura-cb"
    )
    local aur_packages=(
        "arc-gtk-theme"
        "google-chrome"
    )

    pacman_install "${packages[@]}"
    pacman_install "${packages_zathura[@]}"
    aur_install "${aur_packages[@]}"
}

function develop_install() {
    info "Installing develop utils..."

    local packages=(
        "python"
        "go"
        "docker"
        "nodejs"
        "npm"
    )

    pacman_install "${packages[@]}"
}

function laptop_install() {
    local packages=(
        "brightnessctl"
    )

    pacman_install "${packages[@]}"
}

function auto_cpufreq_install() {
    info "Installing auto-cpufreq"

    local required_packages=(
        "git"
        "python-pip"
    )

    pacman_install "${required_packages[@]}"

    execute_user "git clone https://github.com/AdnanHodzic/auto-cpufreq.git ~/auto-cpufreq"
    execute_sudo "
        cd ~/auto-cpufreq
        ./auto-cpufreq-installer
        systemctl enable auto-cpufreq
        systemctl start auto-cpufreq
        systemctl status auto-cpufreq --no-pager
    "
}

function main() {
    base_install
    fonts_install

    if [[ "$DEVICE" != "server" ]]; then
        i3_install
        audio_install
        xorg_install
        gui_install
        additional_install
    fi

    if [[ "$DEVICE" == "laptop" ]]; then
        laptop_install
        auto_cpufreq_install
    fi

    develop_install
}

main
