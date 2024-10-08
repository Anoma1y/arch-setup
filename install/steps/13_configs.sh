#!/bin/bash

function clone_setup_script_repo() {
    info "Cloning setup repo at $1..."

    execute_user "git clone https://github.com/Anoma1y/$SETUP_SCRIPT_REPO $1"
}

function create_config_symlinks() {
    local source_path="$1/configs/.config"
    local output_path="/home/$USER_NAME/.config"
    mapfile -t confs < <(execute_user "ls $source_path | sort")

    execute_user "mkdir -p $output_path"

    execute_user "ln -sf $1/configs/.zshrc /home/$USER_NAME"

    for config in "${confs[@]}"; do
        execute_user "ln -sf $source_path/$config $output_path"
    done
}

function main() {
    local repo_output_dir="/home/$USER_NAME/Projects/$SETUP_SCRIPT_REPO"
    clone_setup_script_repo "$repo_output_dir"
    create_config_symlinks "$repo_output_dir"
}

main
