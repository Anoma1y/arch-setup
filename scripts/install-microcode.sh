#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Installs cpu microcode depending on detected cpu"

proc_type=$(lscpu)
if grep -E "GenuineIntel" <<<"${proc_type}"; then
    echo "Installing Intel microcode"
    pacman -S intel-ucode --noconfirm --needed --color=always
elif grep -E "AuthenticAMD" <<<"${proc_type}"; then
    echo "Installing AMD microcode"
    pacman -S amd-ucode --noconfirm --needed --color=always
fi
