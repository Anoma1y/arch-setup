#!/bin/bash

set -e

function shell_user() {
    local user_name="$1"
    local shell_path="$2"

    info "Setting $shell_path shell for $user_name ..."

    arch-chroot /mnt chsh -s "$shell_path" "$user_name" || danger "Failed to change shell for $user_name"
}

function zsh_pure_theme_install() {
    info "Installing Pure theme for ZSH..."

    execute_user "git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure"
}

function oh_my_zsh_plugins_install() {
    execute_user "
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
    "
}

function oh_my_zsh_install() {
    info "Installing Oh My Zsh..."

    local full_install_path="/home/$USER_NAME/.oh-my-zsh-install"
    local full_path="/mnt/home/$USER_NAME/.oh-my-zsh"

    if [ -d "$full_path" ]; then
        rm -rf "$full_path"
    fi

    execute_user "
        wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -P $full_install_path
        cd $full_install_path
        sh ./install.sh --unattended
        rm -rf $full_install_path
    "
}

function main() {
    local shell_path="/usr/bin/zsh"

    pacman_install "
        git \
        wget \
        alacritty \
        zsh
    "

    shell_user "root" $shell_path
    shell_user "$USER_NAME" $shell_path

    oh_my_zsh_install
    oh_my_zsh_plugins_install

    if [[ ! -d "/mnt/home/$USER_NAME/.zsh/pure" ]]; then
        zsh_pure_theme_install
    fi
}

main
