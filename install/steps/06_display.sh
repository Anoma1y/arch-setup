#!/bin/bash

set -e

function video_drivers_install() {
    info "Trying to install video drivers..."

    local PACKAGES_DRIVER=()
    local PACKAGES_DRIVER_MULTILIB=()

    local PACKAGES_DDX=()

    local PACKAGES_VULKAN=()
    local PACKAGES_VULKAN_MULTILIB=()

    local PACKAGES_HARDWARE_ACCELERATION=()
    local PACKAGES_HARDWARE_ACCELERATION_MULTILIB=()

        if lspci -nn | grep "\[03" | grep -qi "intel"; then
            danger "Nothing to install. Skipping video drivers installation..."
            return
        elif lspci -nn | grep "\[03" | grep -qi "amd"; then
            PACKAGES_DRIVER_MULTILIB=("lib32-mesa")
            PACKAGES_DDX=("xf86-video-amdgpu")
            PACKAGES_VULKAN=("vulkan-radeon" "vulkan-icd-loader")
            PACKAGES_VULKAN_MULTILIB=("lib32-vulkan-radeon" "lib32-vulkan-icd-loader")
            PACKAGES_HARDWARE_ACCELERATION=("libva-mesa-driver")
            PACKAGES_HARDWARE_ACCELERATION_MULTILIB=("lib32-libva-mesa-driver")
        elif lspci -nn | grep "\[03" | grep -qi "nvidia"; then
            PACKAGES_DRIVER=("nvidia")
            PACKAGES_DRIVER_MULTILIB=("lib32-nvidia-utils")
            PACKAGES_VULKAN=("nvidia-utils" "vulkan-icd-loader")
            PACKAGES_VULKAN_MULTILIB=("lib32-nvidia-utils" "lib32-vulkan-icd-loader")
            PACKAGES_HARDWARE_ACCELERATION=("libva-mesa-driver")
            PACKAGES_HARDWARE_ACCELERATION_MULTILIB=("lib32-libva-mesa-driver")
        elif lspci -nn | grep "\[03" | grep -qi "vmware"; then
            danger "Nothing to install. Skipping video drivers installation..."
            return
        else
            warning "GPU vendor is not recognized. Skipping video drivers installation..."
            return
        fi

    # Combine all arrays for base package installation
    local BASE_PACKAGES=("mesa" "mesa-utils" "${PACKAGES_DRIVER[@]}" "${PACKAGES_DDX[@]}" "${PACKAGES_VULKAN[@]}" "${PACKAGES_HARDWARE_ACCELERATION[@]}")
    pacman_install "${BASE_PACKAGES[@]}"

    local MULTILIB_PACKAGES=("${PACKAGES_DRIVER_MULTILIB[@]}" "${PACKAGES_VULKAN_MULTILIB[@]}" "${PACKAGES_HARDWARE_ACCELERATION_MULTILIB[@]}")
    if [ ${#MULTILIB_PACKAGES[@]} -gt 0 ]; then
        pacman_install "${MULTILIB_PACKAGES[@]}"
    fi
}

function main() {
    if [[ "$DEVICE" != "server" ]]; then
        video_drivers_install
    else
        warning "Skip video drivers installation"
    fi
}

main
