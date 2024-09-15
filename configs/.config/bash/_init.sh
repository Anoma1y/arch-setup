#!/bin/bash

scripts=(
    "functions"
    "base"
    "aliases"
    "node"
    "go"
)

for script in "${scripts[@]}"; do
    if [[ "$script" == "_init" ]]; then
        continue
    fi

    if [[ -f "$script" ]]; then
        source "$HOME/.config/bash/$script.sh"
    else
        echo "File $script does not exist."
    fi
done
