#!/bin/bash

set -e

function auto_cpufreq_install() {
    info "Installing auto-cpufreq"

    local required_packages=(
        "git"
        "python-pip"
    )

    pacman_install "${required_packages[@]}"

    execute_user "
        git clone https://github.com/AdnanHodzic/auto-cpufreq.git ~/auto-cpufreq
        cd ~/auto-cpufreq
        ./auto-cpufreq-installer
        systemctl enable auto-cpufreq
        systemctl start auto-cpufreq
        systemctl status auto-cpufreq --no-pager
    "
}

function main() {
    if [[ "$DEVICE" == "laptop" ]]; then
        auto_cpufreq_install
    fi
}

main
