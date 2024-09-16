#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

root_check

# todo add hostname check

ADDITIONAL_HOSTS_FILE="$(pwd)/configs/hosts"

read -r -d '' DEFAULT_HOSTS << EOM
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOM

HOSTNAME=$(hostname)
DEFAULT_HOSTS="$DEFAULT_HOSTS
127.0.1.1       $HOSTNAME"

cp /etc/hosts /etc/hosts.backup

echo "$DEFAULT_HOSTS" > /etc/hosts

cat "$ADDITIONAL_HOSTS_FILE" >> /etc/hosts

print_message info "/etc/hosts has been updated successfully."
print_message info "A backup of the original file is saved as /etc/hosts.backup."
