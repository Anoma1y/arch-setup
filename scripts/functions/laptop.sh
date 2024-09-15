#!/bin/bash

function install_auto_cpufreq() {
    print_message info "Install auto-cpufreq"

    pacman_install git python-pip

    print_message info "Cloning auto-cpufreq repository"
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git ~/auto-cpufreq

    cd ~/auto-cpufreq || exit

    print_message info "Installing auto-cpufreq"
    sudo ./auto-cpufreq-installer

    print_message info "Enabling auto-cpufreq service"
    sudo systemctl enable auto-cpufreq

    print_message info "Starting auto-cpufreq service"
    sudo systemctl start auto-cpufreq

    print_message info "Checking the status of auto-cpufreq service"
    sudo systemctl status auto-cpufreq --no-pager
}
