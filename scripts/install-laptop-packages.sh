#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Install essential laptop packages"
pacman_install_from_config "pacman_laptop"

install_auto_cpufreq
