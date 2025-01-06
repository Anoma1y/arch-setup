#!/bin/bash

AUR_HELPERS=("yay")
DEVICES=("desktop" "laptop" "server")

function sanitize_variables() {
    info "Sanitizing config variables..."

    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")

    if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
        danger "SWAP_SIZE must be a numeric value."
        exit 1
    fi
}

function validate_variables() {
    info "Validating config variables..."

    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALES" "$LOCALES"
    check_variables_value "LOCALE_CONF" "$LOCALE_CONF"

    check_variables_value "ESP_DIRECTORY" "$ESP_DIRECTORY"

    check_variables_boolean "IS_TEST" "$IS_TEST"
    check_variables_boolean "DISK_TRIM" "$DISK_TRIM"
    check_variables_value "SWAPFILE" "$SWAPFILE"

    if [[ $SWAPFILE != /* ]]; then
        SWAPFILE="/$SWAPFILE"
    fi

    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_boolean "PACMAN_PARALLEL_DOWNLOADS" "$PACMAN_PARALLEL_DOWNLOADS"

    check_variables_list "AUR_HELPER" "$AUR_HELPER" AUR_HELPERS[@] "true" "true"

    if [ ${#REFLECTOR_COUNTRIES[@]} -eq 0 ]; then
        danger "No REFLECTOR_COUNTRIES specified."
        exit 1
    fi
}

function validate_prompt_variables() {
    check_variables_list "DEVICE" "$DEVICE" DEVICES[@] "true" "true"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_value "ROOT_PASSWORD" "$ROOT_PASSWORD"
    check_variables_value "DISK_NAME" "$DISK_NAME"
}

function prompts() {
    info "Starting prompts..."

    if [[ $IS_TEST == "true" ]]; then
        USER_NAME="user"
        HOSTNAME="test_host"
        DEVICE="desktop"
        ROOT_PASSWORD="1234"
        USER_PASSWORD="1234"
    else
        password_prompt "ROOT" "ROOT_PASSWORD"

        string_prompt USER_NAME "ayaya"
        success "User name set to: \"$USER_NAME\""

        password_prompt "USER" "USER_PASSWORD"

        string_prompt HOSTNAME "yukari"
        success "Hostname set to: \"$HOSTNAME\""

        select_option DEVICE "${DEVICES[@]}" 1
        success "Device selected: \"$DEVICE\""
    fi

    disk_prompt

    if [ "$IS_TEST" != "true" ]; then
        warning "WARNING: This operation will erase all data on '$DISK_NAME'."
        read -rp "Do you want to continue? (yes/no): " USER_CONFIRMATION

        if [[ "$USER_CONFIRMATION" != "yes" ]]; then
            warning "Operation cancelled by the user."
            exit 1
        fi
    fi
}

function configure_time() {
    info "Configure timedatectl..."

    timedatectl set-ntp true
}

function check_internet_connection() {
    info "Checking internet connection..."

    if ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
        success "Internet connection detected"
    else
        danger "No internet connection detected"
    fi
}

function initialize_pacman_keys() {
    info "Initializing pacman keys..."

    if ! pacman-key --init; then
        danger "Failed to initialize pacman keys."
        exit 1
    fi

    pacman-key --populate

    info "Updating the Arch Linux keyring..."
    pacman -S --noconfirm --color=always archlinux-keyring

    info_sub "Adding the Ubuntu keyserver to the GPG (GNU Privacy Guard) configuration for secure package signing..."
    echo "keyserver hkp://keyserver.ubuntu.com" >> /etc/pacman.d/gnupg/gpg.conf
}

function main() {
    sanitize_variables
    validate_variables
    prompts
    validate_prompt_variables
    check_internet_connection
    configure_time
    pacman -Sy
#    initialize_pacman_keys
}

main
