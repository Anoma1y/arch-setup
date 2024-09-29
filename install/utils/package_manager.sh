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
    pacman_install "git"

    local USER_NAME="$1"
    local COMMAND="$2"

    execute_aur "rm -rf /home/$USER_NAME/.aur-temp && mkdir -p /home/$USER_NAME/.aur-temp/aur && cd /home/$USER_NAME/.aur-temp/aur && git clone https://aur.archlinux.org/${COMMAND}.git && (cd $COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.aur-temp"
}
