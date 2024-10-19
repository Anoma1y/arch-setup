#!/bin/bash

set -e

function kernels_install() {
    info "Installing kernel packages..."

    local packages=("linux-headers")

    pacman_install "${packages[@]}"
}

function main() {
    kernels_install
}

main
