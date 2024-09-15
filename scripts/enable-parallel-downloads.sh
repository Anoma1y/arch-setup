#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Enable parallel downloads in pacman to speed up package installation"
sed -i '/^#ParallelDownloads/s/^#//' /etc/pacman.conf
