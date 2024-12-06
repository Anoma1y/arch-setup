#!/bin/bash

set -e

function initialize_pacman_keys() {
    info "Initializing pacman keys..."

    if ! pacman-key --init; then
        danger "Failed to initialize pacman keys."
        exit 1
    fi

    pacman-key --populate
}

function modify_pacman_conf() {
    local conf_path="$1"

    info "Modifying pacman configuration at $conf_path..."

    # Enable Color
    sed -i 's/^#Color/Color/' "$conf_path"

    if [ "$PACMAN_PARALLEL_DOWNLOADS" == "true" ]; then
        info_sub "Enabling parallel downloads..."
        sed -i 's/^#ParallelDownloads/ParallelDownloads/' "$conf_path"
    else
        info_sub "Disabling parallel downloads and enabling download timeout..."
        sed -i 's/^#ParallelDownloads.*/#ParallelDownloads\nDisableDownloadTimeout/' "$conf_path"
    fi

    info_sub "Enabling Multilib repository..."
    sed -z -i 's/#\[multilib\]\n#/[multilib]\n/' "$conf_path"
}

function update_mirrorlist() {
    info "Updating mirrorlist..."

    pacman -Sy --noconfirm reflector
    reflector --country "${REFLECTOR_COUNTRIES[@]}" \
        --latest 25 \
        --age 24 \
        --protocol https \
        --completion-percent 100 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist
}

function configure_reflector_chroot() {
    info "Installing reflector in chroot environment..."

    arch-chroot /mnt pacman -Sy --noconfirm reflector
    cat <<EOT > "/mnt/etc/xdg/reflector/reflector.conf"
--country ${REFLECTOR_COUNTRIES[@]}
--latest 25
--age 24
--protocol https
--completion-percent 100
--sort rate
--save /etc/pacman.d/mirrorlist
EOT
    info_sub "Running reflector to update mirrorlist..."
    arch-chroot /mnt reflector --country "${REFLECTOR_COUNTRIES[@]}" \
        --latest 25 \
        --age 24 \
        --protocol https \
        --completion-percent 100 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist

    info_sub "Enabling reflector.timer service..."
    arch-chroot /mnt systemctl enable reflector.timer
}

function essential_packages_install() {
    info "Installing essential packages to /mnt ..."

    pacstrap /mnt base base-devel linux linux-firmware
}

function main() {
    initialize_pacman_keys
    update_mirrorlist
    modify_pacman_conf "/etc/pacman.conf"
    essential_packages_install
    modify_pacman_conf "/mnt/etc/pacman.conf"
    configure_reflector_chroot
}

main
