#!/bin/bash

function install_programs() {
    info "Installing programs..."

    local script_dir
    script_dir=$(get_repository_dir)/scripts

    execute_user "
        $script_dir/update_program.sh discord
        $script_dir/update_program.sh vscode
    "
}

function main() {
    install_programs
}

main
