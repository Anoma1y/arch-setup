#!/bin/bash

function root_check() {
    info "Checking if the script is running with root privileges..."

    # Check if the current user ID is not equal to 0 (root user)
    if [[ "$(id -u)" -ne 0 ]]; then
        danger "This script must be run under the 'root' user!"
        exit 1
    fi
}

function non_root_check() {
    info "Checking if the script is running without root privileges..."

    # Check if the current user ID is equal to 0 (root user)
    if [[ "$(id -u)" -eq 0 ]]; then
        danger "This script must not be run as 'root'!"
        exit 1
    fi
}

function efi_check() {
    info "Checking if the system is running in UEFI mode..."

    # Check if the directory '/sys/firmware/efi' exists (indicates UEFI mode)
    if [ ! -d "/sys/firmware/efi" ]; then
        danger "Not running in UEFI mode."
        exit 1
    fi
}
