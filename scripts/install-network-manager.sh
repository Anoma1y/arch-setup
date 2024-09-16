#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Installs network management software"
pacman -S --noconfirm --needed --color=always networkmanager
systemctl enable NetworkManager
