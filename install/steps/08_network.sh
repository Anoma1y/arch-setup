#!/bin/bash

function network_manager_install() {
    info "Installing NetworkManager..."

    pacman_install "networkmanager"
    arch-chroot /mnt systemctl enable NetworkManager.service
}

function main() {
    network_manager_install
    # todo wifi autoconnect
}

main
