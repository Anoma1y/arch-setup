#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

DISK_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --disk=*)
            DISK_NAME="${1#*=}"
            ;;
        --disk)
            shift
            if [[ "$#" -gt 0 ]]; then
                DISK_NAME="$1"
            else
                echo "Error: --disk option requires an argument."
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter passed: $1"
            ;;
    esac
    shift
done

# Check if DISK_NAME was provided
if [[ -z "$DISK_NAME" ]]; then
    echo "Error: The --disk=<disk_name> option is required."
    show_help
fi

# Validate that the disk exists
if [[ ! -b "$DISK_NAME" ]]; then
    echo "Error: Disk '$DISK_NAME' does not exist."
    exit 1
fi

print_message warning "WARNING: This operation will erase all data on '$DISK_NAME'."
read -rp "Do you want to continue? (yes/no): " USER_CONFIRMATION

if [[ "$USER_CONFIRMATION" != "yes" ]]; then
    echo "Operation cancelled by the user."
    exit 1
fi

print_message info "Disk name provided: $DISK_NAME"

# Hiding error message if any
mkdir -p /mnt &>/dev/null
 # make sure everything is unmounted before we start
umount -A --recursive /mnt &>/dev/null

set -e

print_message info "Disk preparation"
# flush all on disk
sgdisk -Z "${DISK}"
# new gpt disk 2048 alignment
sgdisk -a 2048 -o "${DISK}"

print_message info "Creating first partition: EFIBOOT (UEFI Boot Partition)"
sgdisk -n 1::+512M --typecode=1:ef00 --change-name=1:'EFIBOOT' "${DISK}"

print_message info "Creating second partition: ROOT"
sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' "${DISK}"

# reread partition table to ensure it is correct
partprobe "${DISK}"

print_message info "Make filesystems"

# Adjust partition naming for nvme or mmc devices
if [[ "${DISK}" =~ "nvme" || "${DISK}" =~ "mmc" ]]; then
    partition1="${DISK}"p1
    partition2="${DISK}"p2
else
    partition1="${DISK}"1
    partition2="${DISK}"2
fi

print_message info "Creating FAT32 boot filesystem on ${partition1}"
mkfs.vfat -F32 -n "EFIBOOT" "${partition1}"

print_message info "Creating EXT4 root filesystem on ${partition2}"
mkfs.ext4 -L ROOT "${partition2}"
mount -t ext4 "${partition2}" /mnt

set +e

print_message info "Create the directory for the EFI boot partition and mount the EFI system partition"
mkdir -p /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/
