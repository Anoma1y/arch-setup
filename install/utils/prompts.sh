#!/bin/bash

function password_prompt() {
    PASSWORD_NAME="$1"
    PASSWORD_VARIABLE="$2"

    read -r -sp "Enter ${PASSWORD_NAME} password: " PASSWORD1
    echo ""
    read -r -sp "Re-enter ${PASSWORD_NAME} password: " PASSWORD2
    echo ""

    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        declare -n VARIABLE="${PASSWORD_VARIABLE}"
        VARIABLE="$PASSWORD1"
    else
        echo "${PASSWORD_NAME} Passwords don't match."
        password_prompt "${PASSWORD_NAME}" "${PASSWORD_VARIABLE}"
    fi
}

function disk_prompt() {
    disks=($(lsblk -dpno NAME | grep -E "^/dev/(sd|nvme|vd|mmcblk)"))
    if [ ${#disks[@]} -eq 0 ]; then
        danger "No suitable disks found. Exiting."
        exit 1
    fi

    info_sub "Available disks:"
    for i in "${!disks[@]}"; do
        disk="${disks[$i]}"
        size=$(lsblk -dn -o SIZE "$disk")
        model=$(lsblk -dn -o MODEL "$disk")
        echo "$((i+1))) $disk - $size - $model"
    done

    echo
    read -rp "Enter the disk number to install Arch Linux on (e.g., 1): " disk_number
    if [[ "$disk_number" -ge 1 && "$disk_number" -le "${#disks[@]}" ]]; then
        DISK_NAME="${disks[$((disk_number-1))]}"
        success "Arch Linux will be installed on the following disk: $DISK_NAME"
    else
        danger "Invalid selection. Enter a number between 1 and ${#disks[@]}."
        exit 1
    fi
}

