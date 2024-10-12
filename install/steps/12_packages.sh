#!/bin/bash

set -e

function base_install() {
    pacman_install "$PACKAGES_PACMAN_BASE"
    pacman_install "$PACKAGES_PACMAN_ADDITIONAL"
    pacman_install "$PACKAGES_PACMAN_COMPRESSION"
}

function xorg_install() {
    pacman_install "$PACKAGES_PACMAN_XORG"
}

function audio_install() {
    pacman_uninstall "jack2"
    pacman_install "$PACKAGES_PACMAN_AUDIO"
}

function fonts_install() {
    pacman_install "$PACKAGES_PACMAN_FONTS"
    aur_install "$PACKAGES_AUR_FONTS"
}

function additional_install() {
    pacman_install "$PACKAGES_PACMAN_BLUETOOTH"
    pacman_install "$PACKAGES_PACMAN_PRINTER"
    pacman_install "$PACKAGES_PACMAN_USB"
}

function gui_install() {
    pacman_install "$PACKAGES_PACMAN_GUI_APPLICATION"
    aur_install "$PACKAGES_AUR_GUI_APPLICATION"
}

function cli_install() {
    pacman_install "$PACKAGES_PACMAN_CLI_APPLICATION"
}

function develop_install() {
    pacman_install "$PACKAGES_PACMAN_DEVELOPER"
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
