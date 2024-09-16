#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

root_check

while true; do
    read -rp "Enter hostname: " hostname
    [[ "${hostname,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]] && break
    read -rp "Hostname doesn't seem correct. Do you still want to save it? (y/n) " force
    [[ "${force,,}" = "y" ]] && break
done

echo "$hostname" > /etc/hostname
