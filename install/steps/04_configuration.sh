#!/bin/bash

set -e

function configure_systemd_services() {
    info "Enabling fstrim.timer..."

    arch-chroot /mnt systemctl enable fstrim.timer
}

function configure_time() {
    info "Configuring timezone to \"$TIMEZONE\"..."

    arch-chroot /mnt ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    arch-chroot /mnt hwclock --systohc # sync hardware clock with system clock
}

function configure_locale() {
    info "Configure locale..."

    info_sub "Updating locale.gen..."
    for LOCALE in "${LOCALES[@]}"; do
        sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
        sed -i "s/^#${LOCALE}/${LOCALE}/" "/mnt/etc/locale.gen"
    done

    info_sub "Generating locale.conf..."
    for VARIABLE in "${LOCALE_CONF[@]}"; do
        echo -e "${VARIABLE}" >> "/mnt/etc/locale.conf"
    done

    info_sub "Generating locales..."
    locale-gen
    arch-chroot /mnt locale-gen
}

function configure_hostname() {
    info "Setting hostname to \"$HOSTNAME\"..."

    echo "${HOSTNAME}" > "/mnt/etc/hostname"
}

function set_root_password() {
    info "Setting root password..."

    echo -e "${ROOT_PASSWORD}\n${ROOT_PASSWORD}" | arch-chroot /mnt passwd
}

function generate_fstab() {
    info "Generating fstab entries..."

    genfstab -U /mnt >> "/mnt/etc/fstab"

    cat <<EOT >> "/mnt/etc/fstab"
# efivars
efivarfs /sys/firmware/efi/efivars efivarfs ro,nosuid,nodev,noexec 0 0

EOT

    if [[ $SWAP_SIZE -ne "0" ]]; then
        info "Adding swap entry to fstab..."
        cat <<EOT >> "/mnt/etc/fstab"
# swap
${SWAPFILE} none swap defaults 0 0

EOT
    fi

    info "Updating mount options in fstab..."
    sed -i 's/relatime/noatime/' "/mnt/etc/fstab"
}

function main() {
    generate_fstab
    configure_systemd_services
    configure_time
    configure_locale
    configure_hostname
    set_root_password
}

main
