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

function pacman_install() {
    local PACKAGES=("$@")

    pacman -S --noconfirm --needed --color=always "${PACKAGES[@]}"
}

function mirrorlist_update() {
    local REGION="${1:-RU}"

    print_message info "Setting up mirrors for region: $REGION"

    pacman_install reflector
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    reflector -a 48 -c "$REGION" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
}

function install_aur_helper() {
    AUR_HELPER=yay

    git clone https://aur.archlinux.org/$AUR_HELPER.git ~/$AUR_HELPER
    cd ~/$AUR_HELPER || return
    makepkg -si --noconfirm
}

function pacman_install_from_config() {
    local package_array="$1"
    print_message info "Install $package_array packages"

    packages=$(extract_packages_array "$package_array")
    package_list=($(echo "$packages"))

    pacman_install "${package_list[@]}"
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
