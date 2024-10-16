#!/bin/bash

set -e

function systemd_units_enable() {
    info "Enabling/starting systemd services..."

    local systemd_units=(
        "ufw.service"
        "bluetooth.service"
        "docker.service"
    )

    for U in "${systemd_units[@]}"; do
        execute_sudo "systemctl enable $U"
        info_sub "Service $U has been enabled"

        execute_sudo "systemctl start $U"
        info_sub "Service $U has been started"

        execute_sudo "systemctl status $U"
    done
}

function main() {
    systemd_units_enable
}

main
