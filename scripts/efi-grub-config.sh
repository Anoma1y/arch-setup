#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

if [ ! -d "/sys/firmware/efi" ]; then
    print_message danger "Not running in UEFI mode."
    exit 0
fi

print_message info "Grub configuration"
grub-install --efi-directory=/boot --target=x86_64-efi --bootloader-id=grub_uefi --recheck

print_message info "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
