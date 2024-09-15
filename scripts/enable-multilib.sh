#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Enabling multilib"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

print_message info "Syncing repos"
pacman -Sy --noconfirm --needed --color=always
