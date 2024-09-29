#!/bin/bash

function packages_pacman() {
    pacman_install "$PACKAGES_PACMAN_AUDIO"
    pacman_install "$PACKAGES_PACMAN_ESSENTIAL"
    pacman_install "$PACKAGES_PACMAN_CLI_APPLICATION"
}

function packages_aur() {
    aur_install "$PACKAGES_AUR_FONTS"
}

function main() {
#    packages_pacman
#    packages_aur
    echo ""
}

main
