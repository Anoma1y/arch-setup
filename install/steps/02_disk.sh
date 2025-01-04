#!/bin/bash

DISK_ROOT=""
DISK_PARTITION_BOOT=""

function prepare_partition() {
    info "Preparing partitions by unmounting existing mount points..."

    set +e

    if mountpoint -q /mnt/boot; then
        info_sub "Unmounting boot partition..."
        umount /mnt/boot
    fi

    if mountpoint -q /mnt; then
        info_sub "Unmounting root partition..."
        umount /mnt
    fi

    set -e
}

function partition_setup() {
    info "Setting up partition names for boot and root..."

    partprobe -s "$DISK_NAME"

    local boot_number="1"
    local root_number="2"

    case $(get_disk_type) in
        "sda")
            DISK_PARTITION_BOOT="$(get_disk_name "${DISK_NAME}" "${boot_number}")"
            DISK_ROOT="$(get_disk_name "${DISK_NAME}" "${root_number}")"
        ;;
        "nvme")
            DISK_PARTITION_BOOT="$(get_disk_name "${DISK_NAME}" "${boot_number}")"
            DISK_ROOT="$(get_disk_name "${DISK_NAME}" "${root_number}")"
        ;;
    esac
}

function format_disk() {
    info "Formatting the disk and creating partitions..."

    set -e

    # flush all on disk
    sgdisk --zap-all "$DISK_NAME"
    # new gpt disk 2048 alignment
    sgdisk -a 2048 -o "$DISK_NAME"

    wipefs -a -f "$DISK_NAME"
    partprobe -s "$DISK_NAME"

    info_sub "Creating partitions: ESP (fat32) and root (ext4)..."
    parted -s "$DISK_NAME" "mklabel gpt mkpart ESP fat32 1MiB 512MiB mkpart root ext4 512MiB 100% set 1 esp on"

    partprobe -s "$DISK_NAME"

    info_sub "Formatting partitions..."

    # Not fail on error
    wipefs -a -f "$DISK_PARTITION_BOOT" || true
    wipefs -a -f "$DISK_ROOT" || true

    mkfs.fat -n ESP -F32 "$DISK_PARTITION_BOOT"
    mkfs.ext4 -L root "$DISK_ROOT"

    set +e
}

function partition_mount() {
    info "Mounting partitions..."

    local options_boot="defaults,uid=0,gid=0,fmask=0077,dmask=0077"
    local options_root="defaults"

    if [ "$DISK_TRIM" == "true" ]; then
        options_boot="$options_boot,noatime"
    fi

    info_sub "Mounting the ROOT partition..."
    # root
    mount -o "$options_root" "$DISK_ROOT" /mnt

    info_sub "Mounting the BOOT partition..."
    # boot
    mkdir -p /mnt/boot
    mount -o "$options_boot" "$DISK_PARTITION_BOOT" /mnt/boot
}

function create_swap_file() {
    info "Creating swap file of size ${SWAP_SIZE}MB..."

    dd if=/dev/zero of="/mnt$SWAPFILE" bs=1M count="$SWAP_SIZE" status=progress
    chmod 600 "/mnt${SWAPFILE}"
    mkswap "/mnt${SWAPFILE}"

    info_sub "Configuring sysctl for vm.swappiness..."
    echo "vm.swappiness=10" > "/mnt/etc/sysctl.d/99-sysctl.conf"
}

function main() {
    prepare_partition
    partition_setup
    format_disk
    partition_mount

    if [[ $SWAP_SIZE -ne "0" ]]; then
        create_swap_file
    fi
}

main
