#!/bin/bash

function sanitize_variable() {
    local VARIABLE="$1"
    local VARIABLE=$(echo "$VARIABLE" | sed "s/![^ ]*//g")
    local VARIABLE=$(echo "$VARIABLE" | sed -r "s/ {2,}/ /g")
    local VARIABLE=$(echo "$VARIABLE" | sed 's/^[[:space:]]*//')
    local VARIABLE=$(echo "$VARIABLE" | sed 's/[[:space:]]*$//')

    echo "$VARIABLE"
}

function trim_variable() {
    local VARIABLE="$1"
    local VARIABLE=$(echo "$VARIABLE" | sed 's/^[[:space:]]*//')
    local VARIABLE=$(echo "$VARIABLE" | sed 's/[[:space:]]*$//')

    echo "$VARIABLE"
}

function check_variables_value() {
    local NAME="$1"
    local VALUE="$2"
    if [ -z "$VALUE" ]; then
        echo "$NAME environment variable must have a value."
        exit 1
    fi
}

function check_variables_boolean() {
    local NAME="$1"
    local VALUE="$2"

    local list=("true" "false")

    check_variables_list "$NAME" "$VALUE" list[@] "true" "true"
}

function check_variables_list() {
    local NAME="$1"
    local VALUE="$2"
    local VALUES_ARRAY=("${!3}")
    local REQUIRED="$4"
    local SINGLE="$5"

    local VALUES="${VALUES_ARRAY[*]}"

    if [ "$REQUIRED" == "" ] || [ "$REQUIRED" == "true" ]; then
        check_variables_value "$NAME" "$VALUE"
    fi

    if [[ ("$SINGLE" == "" || "$SINGLE" == "true") && "$VALUE" != "" && "$VALUE" =~ " " ]]; then
        echo "$NAME environment variable value [$VALUE] must be a single value of [$VALUES]."
        exit 1
    fi

    if [ "$VALUE" != "" ] && [ -z "$(echo "$VALUES" | grep -F -w "$VALUE")" ]; then #SC2143
        echo "$NAME environment variable value [$VALUE] must be in [$VALUES]."
        exit 1
    fi
}
