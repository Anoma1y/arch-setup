#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils"
STEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps"

function init_configs() {
    source "$ROOT_DIR/_local.conf"
}

function init_utils() {
    source "$UTILS_DIR/utils.sh"
    source "$UTILS_DIR/variables.sh"
    source "$UTILS_DIR/prompts.sh"
    source "$UTILS_DIR/checks.sh"
    source "$UTILS_DIR/package_manager.sh"
}

# Load and sort step files
function load_steps() {
    if [[ ! -d "$STEPS_DIR" ]]; then
        echo "Error: Steps directory '$STEPS_DIR' does not exist."
        exit 1
    fi

    mapfile -t steps < <(ls "$STEPS_DIR" | sort)
}

# Filter steps based on ONLY_STEPS variable
function filter_steps() {
    if [[ -n "${ONLY_STEPS[*]}" ]]; then
        declare -A allowed_steps
        for step in "${ONLY_STEPS[@]}"; do
            allowed_steps["$step"]=1
        done

        local filtered_steps=()
        for file in "${steps[@]}"; do
            local number="${file%%_*}"
            number="${number#0}"

            if [[ ${allowed_steps["$number"]} ]]; then
                filtered_steps+=("$file")
            fi
        done

        steps=("${filtered_steps[@]}")
    fi
}

# Execute each step file
function execute_steps() {
    for file in "${steps[@]}"; do
        local step_path="${STEPS_DIR}/${file}"

        if [[ ! -f "$step_path" ]]; then
            warning "Skipping $step_path: Not a file."
            continue
        fi

        local number="${file%%_*}"
        number="${number#0}"

        if contains SKIP_STEPS "$number"; then
            warning "Skipping $file: Listed in SKIP_STEPS."
            continue
        fi

        if [[ -x "$step_path" ]]; then
                local step_name
                step_name=$(echo "$file" | cut -d'_' -f2 | cut -d'.' -f1)
                format_step "[Start] Step #$number - $step_name"
                source "$step_path"
                format_step "  [End] Step #$number - $step_name"
                echo
            else
                warning "Skipping $file: Not executable."
        fi
    done
}

function display_timestamps() {
    local end_timestamp
    end_timestamp=$(date -u +"%F %T")

    # Calculate duration in seconds
    local start_epoch end_epoch duration
    start_epoch=$(date -d "$START_TIMESTAMP" +%s)
    end_epoch=$(date -d "$end_timestamp" +%s)
    duration=$((end_epoch - start_epoch))

    # Format duration as HH:MM:SS
    INSTALLATION_TIME=$(printf '%02d:%02d:%02d' $((duration/3600)) $(( (duration%3600)/60 )) $((duration%60)))

    echo "  Start time:   $START_TIMESTAMP"
    echo "    End time:   $end_timestamp"
    echo "   Took time:   $INSTALLATION_TIME"
}

function init_log_file() {
    local FILE="/var/log/script_install.log"
    exec &> >(tee -a "$FILE")
}

function main() {
    START_TIMESTAMP=$(date -u +"%F %T")

    init_configs
    init_utils

    efi_check

    load_steps
    filter_steps

    if [[ "$LOG_FILE_ENABLED" == "true" ]]; then
        init_log_file
    fi

    execute_steps

    display_timestamps
}

main
