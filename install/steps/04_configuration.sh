#!/bin/bash

function configure_systemd_services() {
    info "Enabling fstrim.timer..."

    arch-chroot "${MNT_DIR}" systemctl enable fstrim.timer
}

function configure_time() {
    info "Configuring timezone..."

    arch-chroot "${MNT_DIR}" ln -sf "${TIMEZONE}" /etc/localtime
    arch-chroot "${MNT_DIR}" hwclock --systohc
}

function configure_locale() {
    info "Configure locale..."

    info_sub "Configuring locale.gen..."
    for LOCALE in "${LOCALES[@]}"; do
        sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
        sed -i "s/^#${LOCALE}/${LOCALE}/" "${MNT_DIR}/etc/locale.gen"
    done

    info_sub "Generating locale.conf..."
    for VARIABLE in "${LOCALE_CONF[@]}"; do
        echo -e "${VARIABLE}" >> "${MNT_DIR}/etc/locale.conf"
    done

    info_sub "Generating locales..."
    locale-gen
    arch-chroot "${MNT_DIR}" locale-gen
}

function configure_hostname() {
    info "Setting hostname..."

    echo "${HOSTNAME}" > "${MNT_DIR}/etc/hostname"
}

function configure_hosts() {
    info "Setting hosts..."

    local full_path="${MNT_DIR}/etc/hosts"

    cp "$full_path" "$full_path".backup

    read -r -d '' DEFAULT_HOSTS << EOM
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       $HOSTNAME

EOM

    echo "$DEFAULT_HOSTS" > "$full_path"

    echo "# Docker" >> "$full_path"
    cat "$CONFS_DIR/hosts/docker" >> "$full_path"
    echo "" >> "$full_path"

    echo "# M1" >> "$full_path"
    cat "$CONFS_DIR/hosts/m1" >> "$full_path"
    echo "" >> "$full_path"

    info_sub "$full_path has been updated successfully."
    info_sub "A backup of the original file is saved as $full_path.backup."
}

function set_root_password() {
    info "Setting root password..."

    echo -e "${ROOT_PASSWORD}\n${ROOT_PASSWORD}" | arch-chroot "${MNT_DIR}" passwd
}

function main() {
    configure_systemd_services
    configure_time
    configure_locale
    configure_hostname
    configure_hosts
    set_root_password
}

main
