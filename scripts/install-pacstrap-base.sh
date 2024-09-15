#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Install the base system, Linux kernel, Linux-firmware, and additional tools into the mounted target filesystem"
pacstrap /mnt base base-devel linux reflector efibootmgr jq wget rsync curl grub git --noconfirm --needed --color=always
