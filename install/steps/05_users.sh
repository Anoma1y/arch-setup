#!/bin/bash

function create_home_directories() {
    local user_home="${MNT_DIR}/home/${USER_NAME}"

    info "Creating directories in ${user_home}..."

    for dir in "${USER_HOME_DIRECTORIES[@]}"; do
        mkdir -p "${user_home}/${dir}"
        info_sub "Created ${user_home}/${dir}"
    done
}

function add_user() {
    local groups=$(IFS=,; echo "${USER_GROUPS[*]}")

    info "Adding user ${USER_NAME} to groups: ${groups}..."

    arch-chroot "${MNT_DIR}" useradd -m -G "$groups" -c "$USER_NAME" -s /bin/bash "$USER_NAME"
    printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | arch-chroot "${MNT_DIR}" passwd "$USER_NAME"
}

function configure_sudoers() {
    info "Configuring sudoers for wheel group..."

    arch-chroot "${MNT_DIR}" sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

function ensure_additional_groups() {
    for group in "${USER_ADDITIONAL_GROUPS[@]}"; do
        if ! getent group "$group" > /dev/null 2>&1; then
            info "Creating group '$group'..."
            groupadd "$group"
        fi
    done
}

function main() {
    ensure_additional_groups
    add_user
    configure_sudoers
    create_home_directories
}

main
