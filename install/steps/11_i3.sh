#!/bin/bash

set -e

function i3_install() {
    info "Installing I3 packages..."

    pacman_install "$PACKAGES_PACMAN_I3"
}

function main() {
    i3_install
}

main
