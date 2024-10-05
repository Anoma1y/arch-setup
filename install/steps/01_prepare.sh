#!/bin/bash

function sanitize_variables() {
    info "Sanitizing config variables..."

    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    AUR_PACKAGE=$(sanitize_variable "$AUR_PACKAGE")
}

function validate_variables() {
    info "Validating config variables..."

    check_variables_list "DEVICE" "$DEVICE" $DEVICES "true" "true"

    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALES" "$LOCALES"
    check_variables_value "LOCALE_CONF" "$LOCALE_CONF"

    check_variables_value "DISK_NAME" "$DISK_NAME"
    check_variables_boolean "DISK_TRIM" "$DISK_TRIM"
    check_variables_value "SWAPFILE" "$SWAPFILE"

    if [[ $SWAPFILE != /* ]]; then
        SWAPFILE="/$SWAPFILE"
    fi

    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_boolean "PACMAN_PARALLEL_DOWNLOADS" "$PACMAN_PARALLEL_DOWNLOADS"

    check_variables_list "AUR_PACKAGE" "$AUR_PACKAGE" "yay-bin yay" "true" "true"
    check_variables_list "AUR_COMMAND" "$AUR_COMMAND" "yay" "true" "true"

    check_variables_boolean "LOG_FILE" "$LOG_FILE"
    check_variables_value "LOG_FILE_NAME" "$LOG_FILE_NAME"
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

function init_logs() {
    info "Init log file..."

    echo "" > "$LOG_FILE_NAME"
    exec &> >(tee -a "$LOG_FILE_NAME")
}

function prompts() {
    info "Starting prompts..."

    if [ -n "$WIFI_INTERFACE" ] && [ "$WIFI_KEY" == "ask" ]; then
        password_prompt "WIFI" "WIFI_KEY"
    fi

    if [ -z "$ROOT_PASSWORD" ]; then
        password_prompt "ROOT" "ROOT_PASSWORD"
    fi

    if [ -z "$USER_PASSWORD" ]; then
        password_prompt "USER" "USER_PASSWORD"
    fi

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

function configure_network() {
    info "Configure network..."

    if [ -n "$WIFI_INTERFACE" ]; then
        info_sub "Attempting to connect to Wi-Fi SSID: $WIFI_ESSID"
        iwctl --passphrase "$WIFI_KEY" station "$WIFI_INTERFACE" connect "$WIFI_ESSID"
        sleep 10
    fi

    # only one ping -c 1, ping gets stuck if -c 5
    if ! ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
        danger "Network ping check failed. Cannot continue."
        exit 1
    fi
}

function add_key_server() {
    info "Updating the Arch Linux keyring..."
    pacman -S --noconfirm --color=always archlinux-keyring

    info_sub "Adding the Ubuntu keyserver to the GPG (GNU Privacy Guard) configuration for secure package signing..."
    echo "keyserver hkp://keyserver.ubuntu.com" >>/etc/pacman.d/gnupg/gpg.conf
}

function main() {
    sanitize_variables
    prompts
    collect_variables
    validate_variables

    if [ "$LOG_FILE" == "true" ]; then
        init_logs
    fi

    configure_time
    configure_network

    pacman -Sy

#    add_key_server
}

main
