#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

pacman_install "pacman_fonts"
aur_install "aur_fonts"
