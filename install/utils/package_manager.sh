#!/bin/bash

function pacman_install() {
    local ERROR="true"
    local PACKAGES=()

    set +e

    IFS=' ' read -ra PACKAGES <<< "$1"

    for VARIABLE in {1..5}; do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[*]}"

        if execute_sudo "$COMMAND"; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done

    set -e

    if [ "$ERROR" == "true" ]; then
        exit 1
    fi
}

function execute_aur() {
    local COMMAND="$1"

    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        # Temporarily enable NOPASSWD for wheel group
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
        arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    else
        bash -c "$COMMAND"
    fi
}

function aur_install() {
    local ERROR="true"
    local PACKAGES=()

    set +e

    which "$AUR_COMMAND"

    if [ "$AUR_COMMAND" != "0" ]; then
        aur_command_install "$USER_NAME" "$AUR_PACKAGE"
    fi

    IFS=' ' read -ra PACKAGES <<< "$1"

    for VARIABLE in {1..5}; do
        local COMMAND="$AUR_COMMAND -Syu --noconfirm --needed ${PACKAGES[*]}"

        if execute_aur "$COMMAND"; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done

    set -e

    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function aur_command_install() {
#    pacman_install "git"

    local USER_NAME="$1"
    local AUR_PACKAGE="$2"
    local AUR_TEMP_DIR="/home/$USER_NAME/.aur-temp"

    echo "USER_NAME: $USER_NAME"
    echo "AUR_PACKAGE: $AUR_PACKAGE"
    echo "AUR_TEMP_DIR: $AUR_TEMP_DIR"

#    execute_aur "rm -rf $AUR_TEMP_DIR && mkdir -p $AUR_TEMP_DIR"
#    execute_aur "cd $AUR_TEMP_DIR && git clone https://aur.archlinux.org/${AUR_PACKAGE}.git && cd $AUR_PACKAGE && makepkg -si --noconfirm"
#    execute_aur "rm -rf $AUR_TEMP_DIR"
}
