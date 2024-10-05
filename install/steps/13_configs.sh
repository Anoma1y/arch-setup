#!/bin/bash

function clone_setup_script_repo() {
    info "Cloning setup repo at $SETUP_SCRIPT_OUTPUT_DIR..."

    execute_user "git clone https://github.com/Anoma1y/$SETUP_SCRIPT_REPO $SETUP_SCRIPT_OUTPUT_DIR"
}

function create_config_symlinks() {
    echo ""
}

function main() {
    local output_dir="$SETUP_SCRIPT_OUTPUT_DIR/$SETUP_SCRIPT_REPO"

    create_config_symlinks "$output_dir"
}

main
