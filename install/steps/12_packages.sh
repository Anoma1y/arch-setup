#!/bin/bash

set -e

function base_install() {
    pacman_install "$PACKAGES_PACMAN_BASE"
    pacman_install "$PACKAGES_PACMAN_COMPRESSION"
}

function audio_and_video_install() {
    pacman_install "$PACKAGES_PACMAN_XORG"
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

function main() {
    base_install
    audio_and_video_install
    fonts_install
    additional_install
    gui_install
}

main
