#!/bin/bash

set -e

function i3_install() {
    info "Installing I3 packages..."

    pacman_install "
        i3-wm \
        polybar \
        rofi \
        xss-lock \
        i3lock \
        dunst
    "
}

function main() {
    i3_install
}

main
