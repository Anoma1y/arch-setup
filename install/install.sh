#!/bin/bash

CONFS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/conf"
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils"
STEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps"

function init_configs() {
    source "$CONFS_DIR/_local.conf"
    source "$CONFS_DIR/default.conf"
    source "$CONFS_DIR/packages.conf"
}

function init_utils() {
    source "$UTILS_DIR/utils.sh"
    source "$UTILS_DIR/variables.sh"
    source "$UTILS_DIR/prompts.sh"
    source "$UTILS_DIR/checks.sh"
    source "$UTILS_DIR/package_manager.sh"
}

function main() {
    local START_TIMESTAMP=$(date -u +"%F %T")

    init_configs
    init_utils

    efi_check

    steps=($(ls "$STEPS_DIR" | sort))

    if [[ -n "${ONLY_STEPS[*]}" ]]; then
        local tmp_steps=()

        for FILE_NAME in "${steps[@]}"; do
            local number="${FILE_NAME%%_*}"
            number="${number#0}"

            if contains ONLY_STEPS "$number"; then
                tmp_steps+=("$FILE_NAME")
            fi
        done

        steps=("${tmp_steps[@]}")
    fi

    for FILE_NAME in "${steps[@]}"; do
        FILE="$STEPS_DIR/$FILE_NAME"

        local number="${FILE_NAME%%_*}"
        number="${number#0}"

        if contains SKIP_STEPS "$number"; then
            warning "Skipping $FILE_NAME: Listed in SKIP_STEPS."
            continue
        fi

        if [[ -f "$FILE" ]]; then
            STEP_NAME=$(echo "$FILE_NAME" | cut -d'_' -f2 | cut -d'.' -f1)
            format_step "[Start] Step #$number - $STEP_NAME"
            source "$FILE"
            format_step "  [End] Step #$number - $STEP_NAME"
            echo -e ""
        else
            echo "Skipping $FILE: Not executable."
        fi
    done

    local END_TIMESTAMP=$(date -u +"%F %T")
    local INSTALLATION_TIME=$(date -u -d @$(($(date -d "$END_TIMESTAMP" '+%s') - $(date -d "$START_TIMESTAMP" '+%s'))) '+%T')

    echo "  Start time:   $START_TIMESTAMP"
    echo "    End time:   $END_TIMESTAMP"
    echo "   Took time:   $INSTALLATION_TIME"
}

main
