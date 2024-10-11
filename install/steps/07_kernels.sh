#!/bin/bash

set -e

function kernels_install() {
    info "Installing kernel packages..."

    pacman_install "linux-headers"
}

function main() {
    kernels_install
}

main
