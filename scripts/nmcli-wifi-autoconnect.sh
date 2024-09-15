#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Available WiFi networks:"
nmcli device wifi list

read -p "Enter the WiFi name (SSID): " ssid
read -sp "Enter the WiFi password: " password
echo

nmcli device wifi connect "$ssid" password "$password"

if [ $? -eq 0 ]; then
    print_message success "Successfully connected to $ssid."
else
    print_message danger "Failed to connect to $ssid. Please check the name and password."
fi
