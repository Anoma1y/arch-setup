#!/bin/bash

set -e

function auto_cpufreq_install() {
    info "Installing auto-cpufreq"

    pacman_install git python-pip

    execute_user "git clone https://github.com/AdnanHodzic/auto-cpufreq.git ~/auto-cpufreq"
    execute_user "cd ~/auto-cpufreq && ./auto-cpufreq-installer"

    execute_user "systemctl enable auto-cpufreq"
    execute_user "systemctl start auto-cpufreq"
    execute_user "systemctl status auto-cpufreq --no-pager"
}

function main() {
    if [[ "$DEVICE" == "laptop" ]]; then
        auto_cpufreq_install
    else
        info "Skip laptop step"
    fi
}

main
