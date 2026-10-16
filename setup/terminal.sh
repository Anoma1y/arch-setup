#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

SHELL_PATH="/usr/bin/zsh"
OMZ_DIR="${HOME}/.oh-my-zsh"
PURE_DIR="${HOME}/.zsh/pure"
CUSTOM_PLUGINS_DIR="${OMZ_DIR}/custom/plugins"

set_shell() {
    local user_name="$1"

    if [[ "$(getent passwd "$user_name" | cut -d: -f7)" == "$SHELL_PATH" ]]; then
        info_sub "Shell already $SHELL_PATH for $user_name"
        return 0
    fi

    info "Setting login shell to $SHELL_PATH for $user_name"
    sudo chsh -s "$SHELL_PATH" "$user_name"
}

install_oh_my_zsh() {
    if [[ -d "$OMZ_DIR" ]]; then
        info_sub "Oh My Zsh already installed at $OMZ_DIR"
        return 0
    fi

    info "Installing Oh My Zsh (unattended)"
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    curl -fsSL \
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
        -o "$tmp_dir/install.sh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp_dir/install.sh" --unattended
    rm -rf "$tmp_dir"
}

install_plugins() {
    info "Installing Oh My Zsh custom plugins (not bundled upstream)"
    mkdir -p "$CUSTOM_PLUGINS_DIR"

    clone_or_skip \
        "https://github.com/zsh-users/zsh-completions" \
        "$CUSTOM_PLUGINS_DIR/zsh-completions"
}

install_pure() {
    info "Installing Pure prompt"
    mkdir -p "${HOME}/.zsh"
    clone_or_skip "https://github.com/sindresorhus/pure.git" "$PURE_DIR"
}

main() {
    require_not_root

    local packages=(
        git
        wget
        curl
        alacritty
        zsh
    )

    pacman_install "${packages[@]}"

    set_shell "$USER"
    set_shell root

    install_oh_my_zsh
    install_plugins
    install_pure

    success "Terminal setup done. Open a new login shell or run: exec zsh"
    info_sub "Dotfiles (.zshrc, alacritty) are not linked by this script."
}

main "$@"
