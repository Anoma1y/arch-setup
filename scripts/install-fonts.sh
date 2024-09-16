#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

root_check

pacman_install_from_config "pacman_fonts"
aur_install "aur_fonts"

fc-cache -fv
