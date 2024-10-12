#!/bin/bash

set -e

function network_manager_install() {
    info "Installing NetworkManager..."

    pacman_install "networkmanager"
    arch-chroot /mnt systemctl enable NetworkManager.service
}

function autoconnect_to_wifi() {
    if [ -n "$WIFI_INTERFACE" ]; then
        execute_user "nmcli device wifi list"
        execute_user "nmcli device wifi connect $WIFI_ESSID password $WIFI_KEY"
    fi
}

function main() {
    network_manager_install
    autoconnect_to_wifi
}

main
