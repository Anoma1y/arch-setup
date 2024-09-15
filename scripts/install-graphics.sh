#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Installs graphics drivers depending on detected gpu"

gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<<"${gpu_type}"; then
    pacman -S --noconfirm --needed --color=always nvidia-dkms nvidia-settings
    nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed --color=always xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller|Intel Corporation UHD" <<<"${gpu_type}"; then
    pacman -S --noconfirm --needed --color=always libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
else
    echo "No graphics drivers required"
fi
