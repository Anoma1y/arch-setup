#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

pacman_install_from_config "pacman_essential"
#aur_install "aur_fonts"
