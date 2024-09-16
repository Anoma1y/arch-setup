#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

print_message info "Setup Language to US and set locale"

TIMEZONE="Europe/Moscow"

sed -i '/^#en_US.UTF-8 /s/^#//' /etc/locale.gen
locale-gen

timedatectl --no-ask-password set-timezone "${TIMEZONE}"
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

ln -s /usr/share/zoneinfo/"${TIMEZONE}" /etc/localtime

localectl --no-ask-password set-keymap "${KEYMAP}"
