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

# todo
function disk_prompt() {
    lsblk
    local disks=($(lsblk -dpnoNAME | grep -E "^/dev/(sd|nvme|vd)"))

    if [ ${#disks[@]} -eq 0 ]; then
        echo "No suitable disks found. Exiting."
        exit 1
    fi

    info 'Select the number corresponding to the disk (e.g., 1):'

    PS3="Enter the disk number (1-${#disks[@]}): "

    select entry in "${disks[@]}"; do
        if [[ -n "$entry" ]]; then
            disk="$entry"
            warning "Arch Linux will be installed on the following disk: ${disk}"
            DISK_NAME="${disk}"
            break
        else
            echo "Invalid selection. Please enter a number between 1 and ${#disks[@]}."
        fi
    done
}
