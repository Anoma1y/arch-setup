#!/bin/bash

set -e

function create_home_directories() {
    local user_home_path="/home/${USER_NAME}"
    local directories=(
        "Documents"
        "Documents/docs"
        "Documents/obsidian/vaults"
        "Downloads"
        "Pictures"
        "Pictures/screenshots"
        "Videos"
        "Videos/obs"
        "Programs"
        "Projects"
    )

    info "Creating directories in ${user_home_path}..."

    for dir in "${directories[@]}"; do
        local full_dir=${user_home_path}/${dir}

        if [[ -d "/mnt/${full_dir}"  ]]; then
            continue
        fi

        execute_user "mkdir -p ${full_dir}"
        info_sub "Folder \"${dir}\" has been created"
    done
}

function add_user() {
    if arch-chroot "/mnt" id "$USER_NAME" &>/dev/null; then
        info "User \"${USER_NAME}\" already exists. Skipping user creation..."
    else
        local all_groups=("${USER_GROUPS[@]}")
        all_groups+=("${USER_ADDITIONAL_GROUPS[@]}")
        local groups=$(IFS=,; echo "${all_groups[*]}")

        info "Adding user ${USER_NAME} to groups: ${groups}..."

        arch-chroot "/mnt" useradd -m -G "$groups" -c "$USER_NAME" -s /bin/bash "$USER_NAME"
        printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | arch-chroot "/mnt" passwd "$USER_NAME"
    fi
}

function configure_sudoers() {
    info "Configuring sudoers for wheel group..."

    arch-chroot "/mnt" sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

function create_additional_groups() {
    for group in "${USER_ADDITIONAL_GROUPS[@]}"; do
        if arch-chroot "/mnt" id "$USER_NAME" &>/dev/null; then
            ensure_group "$group"
        else
            create_group "$group"
        fi
    done
}

function main() {
    create_additional_groups
    add_user
    configure_sudoers
    create_home_directories
}

main
