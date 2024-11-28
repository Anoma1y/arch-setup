#!/bin/bash

CACHE_DIR="$HOME/.shared"

function log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $1"
}

if [ ! -d "$CACHE_DIR" ]; then
    log "Error: Directory $CACHE_DIR does not exist."
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    log "Warning: It's recommended to run this script with root permissions."
fi

read -p "Are you sure you want to clear the cache in $CACHE_DIR? [y/N]: " CONFIRM
CONFIRM=${CONFIRM,,}

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
    log "Operation cancelled by the user."
    exit 0
fi

log "Clearing cache in $CACHE_DIR..."

rm -rf "${CACHE_DIR:?}/"*

if [ "$(ls -A "$CACHE_DIR")" ]; then
    log "Cache clearing completed, but some files remain."
else
    log "Cache has been successfully cleared."
fi

exit 0
