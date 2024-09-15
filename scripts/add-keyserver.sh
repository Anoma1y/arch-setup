#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Update the Arch Linux keyring"
pacman -S --noconfirm --color=always archlinux-keyring

print_message info "Add the Ubuntu keyserver to the GPG (GNU Privacy Guard) configuration for secure package signing"
echo "keyserver hkp://keyserver.ubuntu.com" >>/etc/pacman.d/gnupg/gpg.conf
