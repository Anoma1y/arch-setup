#!/bin/bash

function multilib_enable() {
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        print_message info "Multilib already enabled"
    else
        print_message info "Enabling multilib"
        sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

        print_message info "Syncing repos"
        pacman -Sy --noconfirm --needed --color=always
    fi
}

function mirrorlist_update() {
    local REGION="${1:-RU}"

    print_message info "Setting up mirrors for region: $REGION"

    pacman -S --noconfirm --needed --color=always reflector
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    reflector -a 48 -c "$REGION" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
}

function install_aur_helper() {
    AUR_HELPER=yay

    git clone https://aur.archlinux.org/$AUR_HELPER.git ~/$AUR_HELPER
    cd ~/$AUR_HELPER || return
    makepkg -si --noconfirm
}

function pacman_install() {
    local package_array="$1"
    print_message info "Install $1 packages"

    for line in $(extract_packages_array "$package_array")
    do
        pacman -S "$line" --noconfirm --needed --color=always
    done
}

function aur_install() {
    local package_array="$1"
    print_message info "Install $1 packages from AUR"

    # Check if 'yay' is installed; if not, install it
    if ! command -v yay >/dev/null 2>&1; then
        print_message warning "Yay not found. Installing yay..."
        install_aur_helper
    fi

    for line in $(extract_packages_array "$package_array")
    do
       yay -S "$line" --noconfirm --needed --color=always
    done
}
