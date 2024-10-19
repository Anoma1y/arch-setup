#!/bin/bash

function pacman_install() {
    local ERROR="true"
    local PACKAGES=("$@")

    set +e

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

function pacman_uninstall() {
    local ERROR="true"
    local PACKAGES=("$@")
    local PACKAGES_UNINSTALL=()

    set +e

    for PACKAGE in "${PACKAGES[@]}"; do
        execute_sudo "pacman -Qi $PACKAGE > /dev/null 2>&1"
        local PACKAGE_INSTALLED=$?
        if [ $PACKAGE_INSTALLED == 0 ]; then
            local PACKAGES_UNINSTALL+=("$PACKAGE")
        fi
    done

    if [ -z "${PACKAGES_UNINSTALL[*]}" ]; then
        return
    fi

    local COMMAND="pacman -Rdd --noconfirm ${PACKAGES_UNINSTALL[*]}"
    if execute_sudo "$COMMAND"; then
        local ERROR="false"
    fi

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
    local PACKAGES=("$@")

    set +e

    execute_sudo "which $AUR_HELPER  > /dev/null 2>&1"
    if [[ $? -ne 0 ]]; then
        aur_command_install
    fi

    for VARIABLE in {1..5}; do
        local COMMAND="$AUR_HELPER -Syu --noconfirm --needed ${PACKAGES[*]}"

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
    info "Installing \"$AUR_HELPER\" AUR helper..."

    local required_packages=("git")

    pacman_install "${required_packages[@]}"

    execute_aur "
        cd /tmp
        git clone https://aur.archlinux.org/$AUR_HELPER.git
        cd $AUR_HELPER
        makepkg -si --noconfirm
        rm -rf /tmp/$AUR_HELPER
    "
}
