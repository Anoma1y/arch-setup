#!/bin/bash

set -e

function network_manager_install() {
    info "Installing NetworkManager..."

    local packages=("networkmanager")

    pacman_install "${packages[@]}"

    arch-chroot /mnt systemctl enable NetworkManager.service
}

function autoconnect_to_wifi() {
    if [ -n "$WIFI_INTERFACE" ]; then
        info "Connecting to Wi-Fi..."
        execute_user "nmcli device wifi connect $WIFI_ESSID password $WIFI_KEY"

        if nmcli -t -f active,ssid dev wifi | grep -q '^yes'; then
            success "Successfully connected to Wi-Fi network \"$WIFI_ESSID\""
        else
            danger "Failed to connect to Wi-Fi network \"$WIFI_ESSID\""
        fi
    fi
}

function main() {
    network_manager_install
    autoconnect_to_wifi
}

main
