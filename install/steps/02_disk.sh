#!/bin/bash

function prepare_partition() {
    set +e

    info "Preparing partitions by unmounting existing mount points..."

    if mountpoint -q "${MNT_DIR}"/boot; then
        info_sub "Unmounting boot partition..."
        umount "${MNT_DIR}"/boot
    fi

    if mountpoint -q "${MNT_DIR}"; then
        info_sub "Unmounting root partition..."
        umount "${MNT_DIR}"
    fi

    set -e
}

function partition_setup() {
    info "Setting up partition names for boot and root..."

    partprobe -s "$DISK_NAME"

    case "$DISK_TYPE" in
        "sda")
            DISK_PARTITION_BOOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_BOOT_NUMBER}")"
            DISK_PARTITION_ROOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_ROOT_NUMBER}")"
            DISK_ROOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_ROOT_NUMBER}")"
        ;;
        "nvme")
            DISK_PARTITION_BOOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_BOOT_NUMBER}")"
            DISK_PARTITION_ROOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_ROOT_NUMBER}")"
            DISK_ROOT="$(get_disk_name "${DISK_NAME}" "${DISK_PARTITION_ROOT_NUMBER}")"
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

    info_sub "Mounting the root partition..."
    # root
    mount -o "$DISK_PARTITION_OPTIONS_ROOT" "$DISK_ROOT" "${MNT_DIR}"

    info_sub "Mounting the root partition..."
    # boot
    mkdir -p "${MNT_DIR}"/boot
    mount -o "$DISK_PARTITION_OPTIONS_BOOT" "$DISK_PARTITION_BOOT" "${MNT_DIR}"/boot
}

function create_swap_file() {
    info "Creating swap file of size ${SWAP_SIZE}MB..."

    dd if=/dev/zero of="${MNT_DIR}$SWAPFILE" bs=1M count="$SWAP_SIZE" status=progress
    chmod 600 "${MNT_DIR}${SWAPFILE}"
    mkswap "${MNT_DIR}${SWAPFILE}"

    info_sub "Configuring sysctl for vm.swappiness..."
    echo "vm.swappiness=10" > "${MNT_DIR}/etc/sysctl.d/99-sysctl.conf"
}


function generate_fstab() {
    info "Generating fstab entries..."

    genfstab -U "${MNT_DIR}" >> "${MNT_DIR}/etc/fstab"

    cat <<EOT >> "${MNT_DIR}/etc/fstab"
# efivars
efivarfs /sys/firmware/efi/efivars efivarfs ro,nosuid,nodev,noexec 0 0

EOT

    if [[ $SWAP_SIZE -ne "0" ]]; then
        info "Adding swap entry to fstab..."
        cat <<EOT >> "${MNT_DIR}/etc/fstab"
# swap
${SWAPFILE} none swap defaults 0 0

EOT
    fi

    info "Updating mount options in fstab..."
    sed -i 's/relatime/noatime/' "${MNT_DIR}/etc/fstab"
}

function main() {
    prepare_partition
    partition_setup
    format_disk
    partition_mount

    if [[ $SWAP_SIZE -ne "0" ]]; then
        create_swap_file
    fi

    generate_fstab

    UUID_BOOT=$(blkid -s UUID -o value "$DISK_PARTITION_BOOT")
    UUID_ROOT=$(blkid -s UUID -o value "$DISK_PARTITION_ROOT")
    PARTUUID_BOOT=$(blkid -s PARTUUID -o value "$DISK_PARTITION_BOOT")
    PARTUUID_ROOT=$(blkid -s PARTUUID -o value "$DISK_PARTITION_ROOT")
}

main
