#!/bin/bash

# Determine the directory of this script
FUNCTIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all helper scripts except functions.sh itself
for helper_script in "$FUNCTIONS_DIR"/*.sh; do
    if [[ "$helper_script" == "$FUNCTIONS_DIR/functions.sh" ]]; then
        continue
    fi

    if [[ -f "$helper_script" ]]; then
        source "$helper_script"
    else
        echo "Warning: Cannot source $helper_script"
    fi
done
