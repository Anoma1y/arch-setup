#!/bin/bash

set -e

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

    if [[ "$DEVICE" == "laptop" ]]; then
        execute_user "ln -sf $output_path/i3/config_laptop $output_path/i3/config_machine"
    else
        execute_user "ln -sf $output_path/i3/config_desktop $output_path/i3/config_machine"
    fi
}

function create_tmux_config() {
    local target_path="/home/$USER_NAME/.config/tmux/plugins/catppuccin"
    local version="2.1.2"

    mkdir -p "$target_path"
    execute_user "git clone -b v$version https://github.com/catppuccin/tmux.git $target_path/tmux"
}

function create_xinit_file() {
    info "Creating xinitrc file..."

    execute_user "rsync -a $1/configs/.xinitrc /home/$USER_NAME/.xinitrc"
    execute_sudo "chmod +x /home/$USER_NAME/.xinitrc"
}

function git_config() {
    info "Updating git config..."

    execute_user "
        git config --global user.email \"$GIT_EMAIL\"
        git config --global user.name \"$GIT_NAME\"
    "
}

function add_hosts_entries() {
    local title="$1"
    local filename="$2"
    local source_path="$3"
    local target_path="$3"

    local filepath="$source_path/$filename"

    if [[ -f "$filepath" ]]; then
        info_sub "Adding $title hosts..."
        {
            echo "# $title"
            cat "$filepath"
            echo ""
        } >> "$target_path"
    else
        info_sub "Hosts file $filepath not found, skipping $title hosts."
    fi
}

function configure_hosts() {
    info "Setting hosts..."

    local source_path="$1/configs/hosts"
    local target_path="/etc/hosts"
    local backup_file_name="$target_path".backup

    info_sub "Creating /etc/hosts backup..."
    cp "$target_path" "$backup_file_name"

    info_sub "Writing default hosts entries..."
    cat > "$target_path" <<EOL
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       $HOSTNAME
EOL

    echo "$DEFAULT_HOSTS" > "$target_path"

    # Add custom hosts entries
    add_hosts_entries "Docker" "docker" "$source_path" "$target_path"
    add_hosts_entries "M1" "m1" "$source_path" "$target_path"

    info_sub "Hosts file has been updated successfully."
    info_sub "A backup of the original file is saved as \"$backup_file_name\""
}

function main() {
    local repo_output_dir="/home/$USER_NAME/Projects/$SETUP_SCRIPT_REPO"

    ensure_folder "/home/$USER_NAME/Projects/"

    local packages=(
        "git"
        "rsync"
    )

    pacman_install "${packages[@]}"

    clone_setup_script_repo "$repo_output_dir"
    create_config_symlinks "$repo_output_dir"
    create_xinit_file "$repo_output_dir"
    configure_hosts "$repo_output_dir"
    git_config
}

main
