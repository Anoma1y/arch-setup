#!/bin/bash

function root_check() {
    print_message info "Checking if the script is running with root privileges..."

    # Check if the current user ID is not equal to 0 (root user)
    if [[ "$(id -u)" != "0" ]]; then
        print_message danger "This script must be run under the 'root' user!"
        exit 0
    fi
}

function efi_check() {
    print_message info "Checking if the system is running in UEFI mode..."

    # Check if the directory '/sys/firmware/efi' exists (indicates UEFI mode)
    if [ ! -d "/sys/firmware/efi" ]; then
        print_message danger "Not running in UEFI mode."
        exit 0
    fi
}
