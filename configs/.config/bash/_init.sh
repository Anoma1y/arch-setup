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

    script_path="$HOME/.config/bash/$script.sh";
    if [[ -f "$script_path" ]]; then
        source "$script_path"
    else
        echo "File $script does not exist."
    fi
done
