#!/bin/bash

set -e

function video_drivers_install() {
    info "Install video drivers for $GPU_VENDOR..."

    local PACKAGES_DRIVER=""
    local PACKAGES_DRIVER_MULTILIB=""

    local PACKAGES_DDX=""

    local PACKAGES_VULKAN=""
    local PACKAGES_VULKAN_MULTILIB=""

    local PACKAGES_HARDWARE_ACCELERATION=""
    local PACKAGES_HARDWARE_ACCELERATION_MULTILIB=""

    case "$GPU_VENDOR" in
        "nvidia" )
            local PACKAGES_DRIVER="nvidia"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            local PACKAGES_VULKAN="nvidia-utils vulkan-icd-loader"
            local PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils lib32-vulkan-icd-loader"
            local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
            local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
            ;;
        "amd" )
            local PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            local PACKAGES_DDX="xf86-video-amdgpu"
            local PACKAGES_VULKAN="vulkan-radeon vulkan-icd-loader"
            local PACKAGES_VULKAN_MULTILIB="lib32-vulkan-radeon lib32-vulkan-icd-loader"
            local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
            local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
            ;;
    esac

    pacman_install "mesa mesa-utils $PACKAGES_DRIVER $PACKAGES_DDX $PACKAGES_VULKAN $PACKAGES_HARDWARE_ACCELERATION"

    if [ "$PACKAGES_MULTILIB" == "true" ]; then
        pacman_install "$PACKAGES_DRIVER_MULTILIB $PACKAGES_VULKAN_MULTILIB $PACKAGES_HARDWARE_ACCELERATION_MULTILIB"
    fi
}

function main() {
    if [[ "$DEVICE" != "server" && -n "$GPU_VENDOR" ]]; then
        video_drivers_install
    else
        warning "Skip video drivers installation"
    fi
}

main
