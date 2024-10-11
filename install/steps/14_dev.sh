#!/bin/bash

set -e

function go_install() {
    info "Installing Golang..."

    pacman_install "go"
}

function nodejs_install() {
    info "Installing Frontend utils..."

    info_sub "Installing NodeJS..."
    pacman_install "nodejs"

    info_sub "Installing Nvm..."
    local nvm_version=$(get_latest_github_release "nvm-sh/nvm")
    execute_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh | bash"

    info_sub "Installing and setting default specific NodeJS version: $NODE_VERSION..."
    execute_user "nvm install $NODE_VERSION"
    execute_user "nvm set default $NODE_VERSION"

    info_sub "Installing Yarn..."
    execute_user "corepack enable"
    execute_user "corepack prepare yarn@stable --activate"
}

function main() {
    go_install
    nodejs_install
}

main
