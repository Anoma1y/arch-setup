#!/bin/bash

function initialize_pacman_keys() {
    info "Initializing pacman keys..."

    pacman-key --init
    pacman-key --populate
}

function modify_pacman_conf() {
    info "Modifying pacman configuration at $1..."

    local conf_path="$1"

    sed -i 's/^#Color/Color/' "$conf_path"
    if [ "$PACMAN_PARALLEL_DOWNLOADS" == "true" ]; then
        info_sub "Enabling parallel downloads..."
        sed -i 's/^#ParallelDownloads/ParallelDownloads/' "$conf_path"
    else
        info_sub "Disabling parallel downloads and enabling download timeout..."
        sed -i 's/^#ParallelDownloads.*/#ParallelDownloads\nDisableDownloadTimeout/' "$conf_path"
    fi

    if [ "$PACKAGES_MULTILIB" == "true" ]; then
        info_sub "Enabling [multilib] repository..."
        sed -i '/^\[multilib\]/,/^Include/ s/^#//' "${MNT_DIR}/etc/pacman.conf"
    fi
}

function update_mirrorlist() {
    info "Updating mirrorlist..."

    pacman -Sy --noconfirm reflector
    reflector "${REFLECTOR_COUNTRIES[@]}" \
        --latest 25 \
        --age 24 \
        --protocol https \
        --completion-percent 100 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist
}

function configure_reflector_chroot() {
    info "Installing reflector in chroot environment..."

    arch-chroot "${MNT_DIR}" pacman -Sy --noconfirm reflector
    cat <<EOT > "${MNT_DIR}/etc/xdg/reflector/reflector.conf"
${REFLECTOR_COUNTRIES[@]}
--latest 25
--age 24
--protocol https
--completion-percent 100
--sort rate
--save /etc/pacman.d/mirrorlist
EOT
    info_sub "Running reflector to update mirrorlist..."
    arch-chroot "${MNT_DIR}" reflector "${REFLECTOR_COUNTRIES[@]}" \
        --latest 25 \
        --age 24 \
        --protocol https \
        --completion-percent 100 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist

    info_sub "Enabling reflector.timer service..."
    arch-chroot "${MNT_DIR}" systemctl enable reflector.timer
}

function essential_packages_install() {
    info "Installing essential packages at $MNT_DIR..."

    pacstrap "${MNT_DIR}" "$PACKAGES_PACMAN_ESSENTIAL"
}

function main() {
    initialize_pacman_keys
    update_mirrorlist
    modify_pacman_conf "/etc/pacman.conf"
    essential_packages_install
    modify_pacman_conf "${MNT_DIR}/etc/pacman.conf"
    configure_reflector_chroot
}

main
