#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Install I3"
pacman_install_from_config "pacman_i3"

if [[ ! -e "$HOME/.xinitrc" ]]; then
    echo "exec i3" > "$HOME/.xinitrc"
fi


