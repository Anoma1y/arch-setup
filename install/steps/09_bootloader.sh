#!/bin/bash

set -e

function mkinitcpio_configuration() {
    info "Mkinitcpio configuration..."

    local HOOKS="base systemd autodetect modconf block filesystems keyboard fsck"
    local MODULES=""

    # Ensure systemd and sd-vconsole are included
    HOOKS=${HOOKS//!systemd/systemd}
    HOOKS=${HOOKS//!sd-vconsole/sd-vconsole}

    HOOKS=$(sanitize_variable "$HOOKS")
    MODULES=$(sanitize_variable "$MODULES")

    arch-chroot /mnt sed -i "s/^HOOKS=(.*)$/HOOKS=($HOOKS)/" /etc/mkinitcpio.conf
    arch-chroot /mnt sed -i "s/^MODULES=(.*)/MODULES=($MODULES)/" /etc/mkinitcpio.conf

    arch-chroot /mnt mkinitcpio -P
}

function grub_install() {
    info "Installing and configuring GRUB..."

    pacman_install "efibootmgr grub dosfstools os-prober"

    arch-chroot /mnt grub-install --target=x86_64-efi \
        --efi-directory=${ESP_DIRECTORY} \
        --bootloader-id=GRUB \
        --recheck

    # Generate the GRUB configuration file
    arch-chroot /mnt grub-mkconfig -o ${BOOT_DIRECTORY}/grub/grub.cfg
}

function microcode_install() {
    info "Installing microcode..."

    case $CPU_VENDOR in
        "intel")
            info_sub "Installing Intel microcode..."
            pacman_install "intel-ucode"
        ;;
        "amd")
            info_sub "Installing AMD microcode..."
            pacman_install "amd-ucode"
        ;;
    esac
}

function main() {
    microcode_install
    grub_install
    mkinitcpio_configuration
}

main
