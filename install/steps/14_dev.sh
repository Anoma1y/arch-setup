#!/bin/bash

set -e

function nvm_install() {
    info "Installing nvm..."

    local nvm_version=$(get_latest_github_release "nvm-sh/nvm")

    execute_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh | bash"

    info_sub "Installing and setting default specific NodeJS version: $NODE_VERSION..."
    execute_user "
        source /home/$USER_NAME/.nvm/nvm.sh
        nvm install $NODE_VERSION
        nvm alias default $NODE_VERSION
    "
}

function yarn_install() {
    info "Installing yarn..."

    execute_sudo "
        corepack enable
        corepack prepare yarn@stable --activate
        corepack enable pnpm
    "
}

function docker_config() {
    info "Adding user \"$USER_NAME\" to the docker group..."

    execute_sudo "usermod -aG docker $USER_NAME"
}

function main() {
    nvm_install
    yarn_install
    docker_config
}

main
