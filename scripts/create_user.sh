#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

function password_prompt() {
    read -rs -p "Please enter password: " PASSWORD1
    echo -ne "\n"
    read -rs -p "Please re-enter password: " PASSWORD2
    echo -ne "\n"
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        PASSWORD="$PASSWORD1"
    else
        echo -ne "ERROR! Passwords do not match. \n"
        password_prompt
    fi
}

function username_prompt() {
    while true; do
        read -rp "Enter username: " username
        [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]] && break
        echo "Incorrect username."
    done
    USERNAME="${username,,}" # convert to lower case
}

username_prompt
password_prompt

echo "$USERNAME"
echo "$PASSWORD"

useradd -m -G wheel,libvirt -s /bin/bash "$USERNAME"

if ! getent group libvirt > /dev/null 2>&1; then
    groupadd libvirt
    echo "Group 'libvirt' has been created."
fi

useradd -m -G wheel,libvirt -s /bin/bash "$USERNAME"
echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"

# use chpasswd to enter $USERNAME:$password
echo "$USERNAME":"$PASSWORD" | chpasswd
echo "$USERNAME password set"
