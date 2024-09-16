#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

check_root

print_message info "Installing docker"
pacman_install docker

print_message info "Enabling Docker service to start on boot"
systemctl enable docker.service
print_message info "Starting Docker service"
systemctl start docker.service

# Determine the non-root user
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    USER_TO_ADD="$SUDO_USER"
else
    # If SUDO_USER is not set, prompt for the username
    read -p "Enter the username to add to the docker group: " USER_TO_ADD
    # Validate the user exists
    if ! id "$USER_TO_ADD" &>/dev/null; then
        print_message danger "User '$USER_TO_ADD' does not exist."
        exit 1
    fi
fi

# Prompt the user for adding to the docker group
read -p "Would you like to add user '$USER_TO_ADD' to the docker group? (y/n): " choice
case "$choice" in
    y|Y )
        usermod -aG docker "$USER_TO_ADD"
        print_message info "User '$USER_TO_ADD' has been added to the docker group."
        print_message warning "Log out and log back in for the changes to take effect."
        ;;
    * )
        print_message info "Skipping adding user to docker group."
        ;;
esac

print_message info "Installing Docker Compose"
pacman_install docker-compose

print_message info "Verifying Docker installation"
docker --version

print_message info "Verifying Docker Compose installation"
docker-compose --version
