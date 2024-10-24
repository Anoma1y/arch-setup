#!/bin/bash

function sanitize_variables() {
    info "Sanitizing config variables..."

    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    # todo add size format check
}

function validate_variables() {
    info "Validating config variables..."

    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALES" "$LOCALES"
    check_variables_value "LOCALE_CONF" "$LOCALE_CONF"

    check_variables_boolean "DISK_TRIM" "$DISK_TRIM"
    check_variables_value "SWAPFILE" "$SWAPFILE"

    if [[ $SWAPFILE != /* ]]; then
        SWAPFILE="/$SWAPFILE"
    fi

    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_boolean "PACMAN_PARALLEL_DOWNLOADS" "$PACMAN_PARALLEL_DOWNLOADS"

    check_variables_list "AUR_HELPER" "$AUR_HELPER" AUR_HELPERS[@] "true" "true"
}

function validate_prompt_variables() {
    check_variables_list "DEVICE" "$DEVICE" DEVICES[@] "true" "true"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_value "ROOT_PASSWORD" "$ROOT_PASSWORD"
    check_variables_value "DISK_NAME" "$DISK_NAME"
}

function collect_variables() {
    info "Collecting variables..."

    if lscpu | grep -q "GenuineIntel"; then
        CPU_VENDOR="intel"
    elif lscpu | grep -q "AuthenticAMD"; then
        CPU_VENDOR="amd"
    fi

    if lspci -nn | grep "\[03" | grep -qi "intel"; then
        GPU_VENDOR="intel"
    elif lspci -nn | grep "\[03" | grep -qi "amd"; then
        GPU_VENDOR="amd"
    elif lspci -nn | grep "\[03" | grep -qi "nvidia"; then
        GPU_VENDOR="nvidia"
    elif lspci -nn | grep "\[03" | grep -qi "vmware"; then
        GPU_VENDOR="vmware"
    fi

    if [ "$(whoami)" == "root" ]; then
        SYSTEM_INSTALLATION="true"
    fi

    if echo "$DISK_NAME" | grep -q "^/dev/sd[a-z]"; then
        DISK_TYPE="sda"
    elif echo "$DISK_NAME" | grep -q "^/dev/nvme"; then
        DISK_TYPE="nvme"
    fi

    if [ "$DISK_TRIM" == "true" ]; then
        DISK_PARTITION_OPTIONS_BOOT="$DISK_PARTITION_OPTIONS_BOOT,noatime"
        DISK_PARTITION_OPTIONS="$DISK_PARTITION_OPTIONS,noatime"
    fi
}

function prompts() {
    info "Starting prompts..."

    password_prompt "ROOT" "ROOT_PASSWORD"

    string_prompt USER_NAME "ayaya"
    success "User name set to: \"$USER_NAME\""

    password_prompt "USER" "USER_PASSWORD"

    string_prompt HOSTNAME "yukari"
    success "Hostname set to: \"$HOSTNAME\""

    select_option DEVICE "${DEVICES[@]}" 1
    success "Device selected: \"$DEVICE\""

    disk_prompt

    if [ "$SKIP_START_WARNING" == "false" ]; then
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

function add_key_server() {
    info "Updating the Arch Linux keyring..."
    pacman -S --noconfirm --color=always archlinux-keyring

    info_sub "Adding the Ubuntu keyserver to the GPG (GNU Privacy Guard) configuration for secure package signing..."
    echo "keyserver hkp://keyserver.ubuntu.com" >> /etc/pacman.d/gnupg/gpg.conf
}

function check_internet_connection() {
    info "Checking internet connection..."

    if ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
        success "Internet connection detected"
    else
        danger "No internet connection detected"
    fi
}

function main() {
    sanitize_variables
    validate_variables

    prompts

    validate_prompt_variables
#    collect_variables
#
#    check_internet_connection
#
#    configure_time
#
#    pacman -Sy
#
#    add_key_server
}

main
