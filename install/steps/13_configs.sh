#!/bin/bash

set -e


function clone_setup_script_repo() {
    info "Cloning setup script repository..."

    clone_or_update_git_repo "https://github.com/Anoma1y/$SETUP_SCRIPT_REPO" "$(get_repository_dir)"
}

function init_home_bin_dir() {
    info "Creating .local/bin directory..."
    execute_user "mkdir -p $(get_local_bin_dir)"
}

function create_config_symlinks() {
    local source_path output_path backup_path
    local exclude=("i3")

    source_path="$(get_repository_dir)/configs/.config"
    output_path="$(get_home_dir)/.config"
    backup_path="$(get_home_dir)/.config_backup"

    mapfile -t confs < <(execute_user "ls $source_path | sort")

    execute_user "mkdir -p $output_path $backup_path"
    execute_user "sed 's|<USER_NAME>|$USER_NAME|g' $source_path/flameshot/flameshot.template.ini > $source_path/flameshot/flameshot.ini"

    for config in "${confs[@]}"; do
        if contains exclude "$config"; then
            continue
        fi

        local target="$output_path/$config"
        if [ -e "$target" ] || [ -L "$target" ]; then
            local timestamp=$(date +%Y%m%d%H%M%S)
            execute_user "mv $target $backup_path/${config}.bak_$timestamp"
            info "Existing $config backed up to $backup_path/${config}.bak_$timestamp"
        fi

        execute_user "ln -sf $source_path/$config $output_path/"
        info_sub "Symlinked $config to $output_path/$config"
    done
}

function create_zsh_config() {
    info "Creating and symlinking ZSH config..."

    local source_path
    source_path="$(get_repository_dir)/configs"

    execute_user "ln -sf $source_path/.zshrc $(get_home_dir)/.zshrc"
}

function create_i3_config() {
    info "Creating i3 config..."

    local source_path output_path

    source_path="$(get_repository_dir)/configs/.config/i3"
    output_path="$(get_home_dir)/.config/i3"

    local config_machine="config_desktop"
    [[ "$DEVICE" == "laptop" ]] && config_machine="config_laptop"

    execute_user "
        mkdir -p $output_path
        ln -sf $source_path/$config_machine $output_path/config_machine
        ln -sf $source_path/config $output_path
        ln -sf $source_path/workspaces $output_path
        ln -sf $source_path/config_common $output_path
    "
}

function create_tmux_config() {
    info "Creating tmux config..."

    local target_path
    target_path="$(get_home_dir)/.config/tmux/plugins/catppuccin"
    local version="2.1.3"

    execute_user "mkdir -p $target_path"
    clone_or_update_git_repo "https://github.com/catppuccin/tmux.git" "$target_path" "v$version"
    execute_user "
        ln -sf $(get_repository_dir)/configs/.tmux.conf $(get_home_dir)/.tmux.conf
    "
}

function create_xinitrc_file() {
    info "Creating xinitrc file..."

    execute_user "rsync -a $(get_repository_dir)/configs/.xinitrc $(get_home_dir)/.xinitrc"
    execute_sudo "chmod +x $(get_home_dir)/.xinitrc"
}

function git_config() {
    info "Updating git config..."

    execute_user "
        git config --global user.email \"$GIT_EMAIL\"
        git config --global user.name \"$GIT_NAME\"
        git config --global core.editor /usr/bin/nvim
    "
}

function add_hosts_entries() {
    local title="$1"
    local source_path target_path

    source_path=$(add_mnt_prefix "$3/$2")
    target_path=$(add_mnt_prefix "$4")

    if [[ -f "$source_path" ]]; then
        info_sub "Adding $title hosts..."
        {
            echo "# $title"
            cat "$source_path"
            echo ""
        } >> "$target_path"
    else
        info_sub "Hosts file $source_path not found, skipping $title hosts."
    fi
}

function configure_hosts() {
    info "Setting hosts..."

    local source_path
    local target_path="/etc/hosts"
    local backup_file_name="$target_path".backup

    source_path="$(get_repository_dir)/configs/hosts"

    info_sub "Creating /etc/hosts backup..."
    execute_sudo "cp $target_path $backup_file_name"

    info_sub "Writing default hosts entries..."
    execute_sudo "
        cat > $target_path <<EOL
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       $HOSTNAME

EOL
    "

    # Add custom hosts entries
    add_hosts_entries "Docker" "docker" "$source_path" "$target_path"
    add_hosts_entries "M1" "m1" "$source_path" "$target_path"

    info_sub "Hosts file has been updated successfully."
    info_sub "A backup of the original file is saved as \"$backup_file_name\""
}

function nemo_config() {
    info "Initializing nemo config..."

    local source_path
    source_path="$(get_repository_dir)/configs"

    execute_user "
        mkdir -p $(get_local_share_dir)
        ln -sf $source_path/nemo $(get_local_share_dir)
    "
}

function create_script_symlinks() {
    info "Creating script symlinks..."

    local source_path
    source_path="$(get_repository_dir)/scripts"

    local scripts=(
        "resize_image.sh"
        "docker_cleanup.sh"
        "convert_video.sh"
        "convert_image.sh"
        "clear_cache.sh"
        "update_program.sh"
    )

    for script in "${scripts[@]}"; do
        local script_basename="${script%.sh}"
        local source="$source_path/$script"
        local target
        target="$(get_local_bin_dir)/$script_basename"

        execute_user "ln -sf $source $target"
        info_sub "Symlinked $script to $target"
    done
}

function update_setup_script_repo() {
    info "Updating setup script repository..."

    execute_user "
        cd $(get_repository_dir) && git remote set-url origin git@github.com:Anoma1y/$SETUP_SCRIPT_REPO.git
    "
}

function main() {
    local packages=(
        "git"
        "rsync"
    )

    pacman_install "${packages[@]}"

    clone_setup_script_repo
    init_home_bin_dir
    create_config_symlinks
    create_zsh_config
    create_i3_config
    create_tmux_config
    create_xinitrc_file
    configure_hosts
    nemo_config
    create_script_symlinks
    git_config
    update_setup_script_repo
}

main
