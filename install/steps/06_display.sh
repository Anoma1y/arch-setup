#!/bin/bash

set -e

function video_drivers_install() {
    info "Install video drivers for \"$GPU_VENDOR\"..."

    local PACKAGES_DRIVER=()
    local PACKAGES_DRIVER_MULTILIB=()

    local PACKAGES_DDX=()

    local PACKAGES_VULKAN=()
    local PACKAGES_VULKAN_MULTILIB=()

    local PACKAGES_HARDWARE_ACCELERATION=()
    local PACKAGES_HARDWARE_ACCELERATION_MULTILIB=()

    case "$GPU_VENDOR" in
        "nvidia" )
            PACKAGES_DRIVER=("nvidia")
            PACKAGES_DRIVER_MULTILIB=("lib32-nvidia-utils")
            PACKAGES_VULKAN=("nvidia-utils" "vulkan-icd-loader")
            PACKAGES_VULKAN_MULTILIB=("lib32-nvidia-utils" "lib32-vulkan-icd-loader")
            PACKAGES_HARDWARE_ACCELERATION=("libva-mesa-driver")
            PACKAGES_HARDWARE_ACCELERATION_MULTILIB=("lib32-libva-mesa-driver")
            ;;
        "amd" )
            PACKAGES_DRIVER_MULTILIB=("lib32-mesa")
            PACKAGES_DDX=("xf86-video-amdgpu")
            PACKAGES_VULKAN=("vulkan-radeon" "vulkan-icd-loader")
            PACKAGES_VULKAN_MULTILIB=("lib32-vulkan-radeon" "lib32-vulkan-icd-loader")
            PACKAGES_HARDWARE_ACCELERATION=("libva-mesa-driver")
            PACKAGES_HARDWARE_ACCELERATION_MULTILIB=("lib32-libva-mesa-driver")
            ;;
        *)
            warning "GPU vendor '$GPU_VENDOR' is not recognized. Skipping video drivers installation..."
            return
            ;;
    esac

    # Combine all arrays for base package installation
    local BASE_PACKAGES=("mesa" "mesa-utils" "${PACKAGES_DRIVER[@]}" "${PACKAGES_DDX[@]}" "${PACKAGES_VULKAN[@]}" "${PACKAGES_HARDWARE_ACCELERATION[@]}")
    pacman_install "${BASE_PACKAGES[@]}"

    local MULTILIB_PACKAGES=("${PACKAGES_DRIVER_MULTILIB[@]}" "${PACKAGES_VULKAN_MULTILIB[@]}" "${PACKAGES_HARDWARE_ACCELERATION_MULTILIB[@]}")
    if [ ${#MULTILIB_PACKAGES[@]} -gt 0 ]; then
        pacman_install "${MULTILIB_PACKAGES[@]}"
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
