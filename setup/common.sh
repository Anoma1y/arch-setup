#!/usr/bin/env bash

set -euo pipefail

info() {
    printf '\e[1;36m%s\e[0m\n' "$*"
}

info_sub() {
    printf '\e[96m%s\e[0m\n' "$*"
}

success() {
    printf '\e[1;32m%s\e[0m\n' "$*"
}

warning() {
    printf '\e[1;33m%s\e[0m\n' "$*"
}

danger() {
    printf '\e[1;31m%s\e[0m\n' "$*" >&2
}

die() {
    danger "$*"
    exit 1
}

require_not_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        die "Run as a normal user (sudo is used only where needed)."
    fi
}

pacman_install() {
    local packages=("$@")
    info "Installing packages: ${packages[*]}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

clone_or_skip() {
    local url="$1"
    local dest="$2"

    if [[ -d "$dest/.git" ]] || [[ -d "$dest" && -n "$(ls -A "$dest" 2>/dev/null || true)" ]]; then
        info_sub "Already present, skipping: $dest"
        return 0
    fi

    info_sub "Cloning $url → $dest"
    git clone --depth 1 "$url" "$dest"
}
