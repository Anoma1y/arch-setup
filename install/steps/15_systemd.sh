#!/bin/bash

set -e

function systemd_units() {
    info "Enabling/starting systemd services..."

    for U in "${SYSTEMD_UNITS[@]}"; do
        execute_sudo "systemctl enable $U"
        info_sub "Service $U has been enabled"

        execute_sudo "systemctl start $U"
        info_sub "Service $U has been started"

        execute_sudo "systemctl status $U"
    done
}

function main() {
    systemd_units
}

main
