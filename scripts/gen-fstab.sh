#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Generate the fstab file, which defines how disk partitions should be mounted at boot"
genfstab -L /mnt >> /mnt/etc/fstab

print_message info "Display the generated fstab for review: /etc/fstab"
cat /mnt/etc/fstab
