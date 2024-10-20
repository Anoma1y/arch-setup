#!/bin/bash

function sanitize_variables() {
    info "Sanitizing config variables..."

    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    # todo add size format check
}

function validate_variables() {
    info "Validating config variables..."

    check_variables_list "DEVICE" "$DEVICE" "$DEVICES" "true" "true"

    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "HOSTNAME" "$HOSTNAME"
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

    check_variables_list "AUR_HELPER" "$AUR_HELPER" "$AUR_HELPERS" "true" "true"
}

function validate_prompt_variables() {
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

    if [ -z "$ROOT_PASSWORD" ]; then
        password_prompt "ROOT" "ROOT_PASSWORD"
    fi

    if [ -z "$USER_PASSWORD" ]; then
        password_prompt "USER" "USER_PASSWORD"
    fi

    if [ -z "$disk_prompt" ]; then
        disk_prompt
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

function add_key_server() {
    info "Updating the Arch Linux keyring..."
    pacman -S --noconfirm --color=always archlinux-keyring

    info_sub "Adding the Ubuntu keyserver to the GPG (GNU Privacy Guard) configuration for secure package signing..."
    echo "keyserver hkp://keyserver.ubuntu.com" >> /etc/pacman.d/gnupg/gpg.conf
}

function connect_wifi() {
    info "Trying to connect to WiFi network..."

    if ! command -v iwctl >/dev/null 2>&1; then
        danger "iwctl is not available. Ensure iwd is installed"
        exit 1
    fi

    info_sub "Available WiFi devices:"

    mapfile -t devices < <(iwctl device list | awk '/station/{print $2}')
    if [ ${#devices[@]} -eq 0 ]; then
        danger "No WiFi devices found. Exiting."
        exit 1
    fi

    for i in "${!devices[@]}"; do
        echo "$((i+1))) ${devices[$i]}"
    done

    read -rp "Enter the number of the WiFi device to use (e.g., 1): " device_number
    if [[ "$device_number" -ge 1 && "$device_number" -le "${#devices[@]}" ]]; then
        WIFI_INTERFACE="${devices[$((device_number-1))]}"
        info_sub "Selected device: $WIFI_INTERFACE"
    else
        danger "Invalid selection."
        exit 1
    fi

    info_sub "Scanning for available WiFi networks..."
    iwctl station "$WIFI_INTERFACE" scan

    info_sub "Available WiFi networks:"
    mapfile -t networks < <(iwctl station "$WIFI_INTERFACE" get-networks | sed -e '1,4 d' -e $'s/\e\\[[0-9;]*m>*//g' | awk 'NF{NF-=2}1 && NF' | sort -u)
    if [ ${#networks[@]} -eq 0 ]; then
        danger "No WiFi networks found."
        exit 1
    fi

    for i in "${!networks[@]}"; do
        echo "$((i+1))) ${networks[$i]}"
    done

    read -rp "Enter the number of the WiFi network to connect to (e.g., 1): " network_number
    if [[ "$network_number" -ge 1 && "$network_number" -le "${#networks[@]}" ]]; then
        WIFI_ESSID="${networks[$((network_number-1))]}"
        info_sub "Selected network: $WIFI_ESSID"
    else
        danger "Invalid selection."
        exit 1
    fi

    network_info=$(iwctl station "$WIFI_INTERFACE" get-networks | grep "$WIFI_ESSID")
    if echo "$network_info" | grep -q "psk"; then
        read -rsp "Enter WiFi passphrase for $WIFI_ESSID: " WIFI_PASSPHRASE
        echo
    else
        WIFI_PASSPHRASE=""
    fi

    info_sub "Connecting to $WIFI_ESSID..."
    if [ -n "$WIFI_PASSPHRASE" ]; then
        iwctl --passphrase "$WIFI_PASSPHRASE" station "$WIFI_INTERFACE" connect "$WIFI_ESSID"
    else
        iwctl station "$WIFI_INTERFACE" connect "$WIFI_ESSID"
    fi

    info_sub "Verifying internet connection..."
    if ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
        success "Successfully connected to the internet"
    else
        danger "Failed to establish an internet connection"
        exit 1
    fi
}

function check_internet_connection() {
    info "Checking internet connection..."

    if ping -c 1 -i 2 -W 5 -w 30 "$PING_HOSTNAME"; then
        success "Internet connection detected"
    else
        warning "No internet connection detected"
        connect_wifi
    fi
}

function main() {
    sanitize_variables
    validate_variables

    prompts

    validate_prompt_variables
    collect_variables

    check_internet_connection

    configure_time

    pacman -Sy

    add_key_server
}

main
