#!/bin/bash

set -e

function network_manager_install() {
    info "Installing NetworkManager..."

    local packages=("networkmanager")

    pacman_install "${packages[@]}"

    arch-chroot /mnt systemctl enable NetworkManager.service
}

#function connect_wifi() {
#    info "Trying to connect to WiFi network..."
#
#    if ! command -v iwctl >/dev/null 2>&1; then
#        danger "iwctl is not available. Ensure iwd is installed"
#        exit 1
#    fi
#
#    info_sub "Available WiFi devices:"
#
#    mapfile -t devices < <(iwctl device list | awk '/station/{print $2}')
#    if [ ${#devices[@]} -eq 0 ]; then
#        danger "No WiFi devices found. Exiting."
#        exit 1
#    fi
#
#    for i in "${!devices[@]}"; do
#        echo "$((i+1))) ${devices[$i]}"
#    done
#
#    read -rp "Enter the number of the WiFi device to use (e.g., 1): " device_number
#    if [[ "$device_number" -ge 1 && "$device_number" -le "${#devices[@]}" ]]; then
#        WIFI_INTERFACE="${devices[$((device_number-1))]}"
#        info_sub "Selected device: $WIFI_INTERFACE"
#    else
#        danger "Invalid selection."
#        exit 1
#    fi
#
#    info_sub "Scanning for available WiFi networks..."
#    iwctl station "$WIFI_INTERFACE" scan
#
#    info_sub "Available WiFi networks:"
#    mapfile -t networks < <(iwctl station "$WIFI_INTERFACE" get-networks | sed -e '1,4 d' -e $'s/\e\\[[0-9;]*m>*//g' | awk 'NF{NF-=2}1 && NF' | sort -u)
#    if [ ${#networks[@]} -eq 0 ]; then
#        danger "No WiFi networks found."
#        exit 1
#    fi
#
#    for i in "${!networks[@]}"; do
#        echo "$((i+1))) ${networks[$i]}"
#    done
#
#    read -rp "Enter the number of the WiFi network to connect to (e.g., 1): " network_number
#    if [[ "$network_number" -ge 1 && "$network_number" -le "${#networks[@]}" ]]; then
#        WIFI_ESSID="${networks[$((network_number-1))]}"
#        info_sub "Selected network: $WIFI_ESSID"
#    else
#        danger "Invalid selection."
#        exit 1
#    fi
#
#    network_info=$(iwctl station "$WIFI_INTERFACE" get-networks | grep "$WIFI_ESSID")
#    if echo "$network_info" | grep -q "psk"; then
#        read -rsp "Enter WiFi passphrase for $WIFI_ESSID: " WIFI_PASSPHRASE
#        echo
#    else
#        WIFI_PASSPHRASE=""
#    fi
#
#    info_sub "Connecting to $WIFI_ESSID..."
#    if [ -n "$WIFI_PASSPHRASE" ]; then
#        iwctl --passphrase "$WIFI_PASSPHRASE" station "$WIFI_INTERFACE" connect "$WIFI_ESSID"
#    else
#        iwctl station "$WIFI_INTERFACE" connect "$WIFI_ESSID"
#    fi
#
#    info_sub "Verifying internet connection..."
#    if ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
#        success "Successfully connected to the internet"
#    else
#        danger "Failed to establish an internet connection"
#        exit 1
#    fi
#}

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
