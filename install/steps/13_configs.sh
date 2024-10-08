#!/bin/bash

function clone_setup_script_repo() {
    local destination_dir="$1"

    if [[ -d "$destination_dir/.git" ]]; then
        info "Repository already exists in $destination_dir. Pulling latest changes..."
        execute_user "cd $destination_dir && git pull"
    else
        info "Cloning setup repo into $destination_dir..."
        execute_user "git clone https://github.com/Anoma1y/$SETUP_SCRIPT_REPO $destination_dir"
    fi
}

function create_config_symlinks() {
    local source_path="$1/configs/.config"
    local output_path="/home/$USER_NAME/.config"
    local backup_path="/home/$USER_NAME/.config_backup"

    mapfile -t confs < <(execute_user "ls $source_path | sort")

    execute_user "mkdir -p $output_path"
    execute_user "mkdir -p $backup_path"

    if [ -e "/home/$USER_NAME/.zshrc" ]; then
        local timestamp=$(date +%Y%m%d%H%M%S)
        execute_user "mv /home/$USER_NAME/.zshrc $backup_path/.zshrc.bak_$timestamp"
        info_sub ".zshrc backed up to $backup_path/.zshrc.bak_$timestamp"
    fi

    execute_user "ln -sf $1/configs/.zshrc /home/$USER_NAME/.zshrc"
    info_sub "Symlinked .zshrc to /home/$USER_NAME/.zshrc"

    for config in "${confs[@]}"; do
        local target="$output_path/$config"
        if [ -e "$target" ] || [ -L "$target" ]; then
            local timestamp=$(date +%Y%m%d%H%M%S)
            execute_user "mv $target $backup_path/${config}.bak_$timestamp"
            info "Existing $config backed up to $backup_path/${config}.bak_$timestamp"
        fi

        execute_user "ln -sf $source_path/$config $output_path/"
        info "Symlinked $config to $output_path/$config"
    done
}

function create_xinit_file() {
    info "Creating xinitrc file..."
    execute_user "rsync -a $1/configs/.xinitrc /home/$USER_NAME/.xinitrc"
}

function main() {
    local repo_output_dir="/home/$USER_NAME/Projects/$SETUP_SCRIPT_REPO"

    pacman_install "git rsync"

    clone_setup_script_repo "$repo_output_dir"
    create_config_symlinks "$repo_output_dir"
    create_xinit_file "$repo_output_dir"
}

main
