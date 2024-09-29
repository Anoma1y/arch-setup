#!/bin/bash

function kernels_install() {
    info "Installing kernel packages..."

    pacman_install "$PACKAGES_PACMAN_KERNELS"
}

function main() {
    kernels_install
}

main
