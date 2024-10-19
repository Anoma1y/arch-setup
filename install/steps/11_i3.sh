#!/bin/bash

set -e

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

function main() {
    i3_install
}

main
