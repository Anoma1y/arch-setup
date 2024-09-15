#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

efi_check

print_message info "Grub configuration"
grub-install --efi-directory=/boot --target=x86_64-efi --bootloader-id=grub_uefi --recheck

print_message info "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
