#!/bin/bash

function shell_user() {
    local USER="$1"
    local SHELL_PATH="$2"

    info "Setting $SHELL_PATH shell for $USER"

    arch-chroot "${MNT_DIR}" chsh -s "$SHELL_PATH" "$USER"
}

function oh_my_zsh_install() {
    info "Installing Oh My Zsh..."

    local full_path="$MNT_DIR/home/$USER_NAME/.oh-my-zsh"

    if [ -d "$full_path" ]; then
        rm -rf "$full_path"
    fi

    execute_user "$USER_NAME" "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    execute_user "$USER_NAME" "git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions"
    execute_user "$USER_NAME" "git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions"
    execute_user "$USER_NAME" "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting"
}

function main() {
    local SHELL_PATH="/usr/bin/zsh"

    pacman_install "zsh git pacman_terminal"

    shell_user "root" $SHELL_PATH
    shell_user "$USER_NAME" $SHELL_PATH

    oh_my_zsh_install
}

main
