#!/bin/bash

packages_file=$(pwd)/configs/packages.json

# print_message info "This is an info message"
# print_message danger "This is a danger message"
# print_message success "This is a success message"
# print_message warning "This is a warning message"
function print_message(){
    local color_code
    case "$1" in
        info)
            color_code='\e[1;34m'
            ;;
        danger)
            color_code='\e[1;31m'
            ;;
        success)
            color_code='\e[1;32m'
            ;;
        warning)
            color_code='\e[1;33m'
            ;;
        *)
            color_code='\e[0m'
            ;;
    esac
    shift
    printf "${color_code}%-6s\e[m\n" "${@}"
}

function extract_packages_array() {
    local key=$1

    jq -r ".${key}[]" "$packages_file"
}

function concat_with_space() {
    local array=("$@")
    local result=""

    for element in "${array[@]}"; do
        result+="$element "
    done

    result=${result% }

    echo "$result"
}

function choose_option {
    local key="$1"
    shift
    local arr=("$@")
    local choice

    PS3="Enter the number of your choice: "

    select choice in "${arr[@]}"; do
        if [[ -n "$choice" ]]; then
            echo "$choice"
            break
        fi
    done
}
