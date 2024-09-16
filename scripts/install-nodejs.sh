#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Installs Node JS and NVM"

NODE_VERSION="18.16.0"
NVM_VERSION="0.40.1"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --node=*)
            NODE_VERSION="${1#*=}"
            ;;
        --nvm=*)
            NVM_VERSION="${1#*=}"
            ;;
    esac
    shift
done

if ! validate_version "$NODE_VERSION"; then
    print_message danger "Invalid NodeJS version format: $NODE_VERSION. Expected format: xx.xx.xx"
    exit 1
fi

if ! validate_version "$NVM_VERSION"; then
    print_message danger "Invalid NVM version format: $NVM_VERSION. Expected format: xx.xx.xx"
    exit 1
fi

print_message info "Selected versions:"
echo -en "  NodeJS: $NODE_VERSION\n"
echo -en "  NVM: $NVM_VERSION"

pacman -S --noconfirm --needed --color=always nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
nvm install "$NODE_VERSION" # todo need fix
nvm alias default "$NODE_VERSION"
