#!/bin/bash

check_root

TMP_FILE=$(mktemp /etc/sudoers.XXXXXX)

cp --preserve =mode,ownership /etc/sudoers "$TMP_FILE"

sed -i '/^#.*%wheel ALL=(ALL:ALL) ALL/s/^#//' "$TMP_FILE"

if visudo -c -f "$TMP_FILE"; then
    cp --preserve=mode,ownership /etc/sudoers /etc/sudoers.bak
    mv "$TMP_FILE" /etc/sudoers
    echo "Successfully uncommented %wheel in /etc/sudoers and created a backup at /etc/sudoers.bak."
else
    echo "There was an error with the modified sudoers file. No changes were made."
    rm "$TMP_FILE"
    exit 1
fi
