#!/bin/bash

# Function to print info
function info() {
    local color_code='\e[1;36m'  # Light blue (cyan)
    printf "${color_code}%-6s\e[m\n" "${*}"
}

# Function to print info sub
function info_sub() {
    local color_code='\e[96m'  # Brighter cyan
    printf "${color_code}%-6s\e[m\n" "${*}"
}

# Function to print danger
function danger() {
    local color_code='\e[1;31m'  # Red
    printf "${color_code}%-6s\e[m\n" "${*}"
}

# Function to print success
function success() {
    local color_code='\e[1;32m'  # Green
    printf "${color_code}%-6s\e[m\n" "${*}"
}

# Function to print warning
function warning() {
    local color_code='\e[1;33m'  # Yellow
    printf "${color_code}%-6s\e[m\n" "${*}"
}

# Function to print step
function format_step() {
    local color_code='\e[1;35m'  # Light magenta (muted pink)
    printf "${color_code}%-6s\e[m\n" "${*}"
}

function step() {
    local FILE_NAME=$1
    local STATUS=$2
    NUMBER=$(echo "$FILE_NAME" | cut -d'_' -f1)
    NAME=$(echo "$FILE_NAME" | cut -d'_' -f2 | cut -d'.' -f1)

    format_step "[$STATUS] Step #$NUMBER - $NAME"
    if [ "$STATUS" == "End" ]; then
        echo -e ""
    fi
}

function execute_sudo() {
    local COMMAND="$1"

    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        sudo bash -c "$COMMAND"
    fi
}

# Executes a command as the target user, optionally within a chroot environment
function execute_user() {
    local COMMAND="$1"

    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
    else
        bash -c "$COMMAND"
    fi
}

function create_group() {
    local group=$1
    info "Creating group \"$group\"..."
    execute_sudo "groupadd $group"
}

function ensure_group() {
    local group="$1"

    set +e

    execute_user "getent group $group > /dev/null 2>&1"
    if [[ $? -ne 0 ]]; then
        info "Creating group \"$group\"..."
        execute_sudo "groupadd $group"
    fi

    set -e
}

function do_reboot() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

# Function to check if an element is in an array
function contains() {
    local array="$1[@]"
    local seeking=$2
    local in=1

    for element in "${!array}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done

    return $in
}

function starts_with() {
    local text=$1
    local prefix=$2

    if [[ $text == "$prefix"* ]]; then
      return 0
    fi

    return 1
}

# Function to get the correct disk name format depending on the disk type
function get_disk_name() {
    local DISK_NAME="$1"
    local NUMBER="$2"
    local PARTITION_DISK_NAME=""

    case "$DISK_TYPE" in
        "sda")
            PARTITION_DISK_NAME="${DISK_NAME}${NUMBER}"
        ;;
        "nvme")
            PARTITION_DISK_NAME="${DISK_NAME}p${NUMBER}"
        ;;
    esac

    echo "$PARTITION_DISK_NAME"
}

# Function to validate version (xx.xx.xx)
function validate_version() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

function get_latest_github_release() {
    local repo="$1"
    local latest_release=$(curl --silent "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [[ -z "$latest_release" ]]; then
        echo "Could not fetch the latest release for $repo"
        return 1
    fi

    echo "$latest_release"
}
