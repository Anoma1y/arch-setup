#!/bin/bash

function password_prompt() {
    PASSWORD_NAME="$1"
    PASSWORD_VARIABLE="$2"

    read -r -sp "Enter ${PASSWORD_NAME} password: " PASSWORD1
    echo ""
    read -r -sp "Re-enter ${PASSWORD_NAME} password: " PASSWORD2
    echo ""

    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        declare -n VARIABLE="${PASSWORD_VARIABLE}"
        VARIABLE="$PASSWORD1"
    else
        echo "${PASSWORD_NAME} Passwords don't match."
        password_prompt "${PASSWORD_NAME}" "${PASSWORD_VARIABLE}"
    fi
}

function disk_prompt() {
    while true; do
        disks=($(lsblk -dpno NAME | grep -E "^/dev/(sd|nvme|vd|mmcblk)"))
        if [ ${#disks[@]} -eq 0 ]; then
            danger "No suitable disks found. Exiting."
            continue
        fi

        info_sub "Available disks:"
        for i in "${!disks[@]}"; do
            disk="${disks[$i]}"
            size=$(lsblk -dn -o SIZE "$disk")
            model=$(lsblk -dn -o MODEL "$disk")
            echo "$((i+1))) $disk - $size - $model"
        done

        echo
        read -rp "Enter the disk number to install Arch Linux on (e.g., 1): " disk_number
        if [[ "$disk_number" -ge 1 && "$disk_number" -le "${#disks[@]}" ]]; then
            DISK_NAME="${disks[$((disk_number-1))]}"
            success "Arch Linux will be installed on the following disk: $DISK_NAME"
            break
        else
            danger "Invalid selection. Enter a number between 1 and ${#disks[@]}."
            # Loop continues for another retry
        fi
    done
}

# Function to prompt user for input
# Arguments:
#   $1 - The name of the variable to assign the input to.
#   $2 - (Optional) The default value if the user provides no input.
function string_prompt() {
    local var_name="$1"
    local default_value="$2"
    local user_input

    if [[ -n "$default_value" ]]; then
        read -rp "Enter value <$var_name> [Default: $default_value]: " user_input

        if [[ -z "$user_input" ]]; then
            user_input="$default_value"
        fi
    else
        read -rp "Enter value <$var_name>: " user_input
    fi

    printf -v "$var_name" "%s" "$user_input"
}

# Function to prompt user to select from a list
# Arguments:
#   $1 - Variable name to assign the selected value
#   $2 - An array of options (space-separated or array)
#   $3 - (Optional) Default option index (1-based)
function select_option() {
    local var_name="$1"
    shift
    local options=("$@")
    local default_index=0

    # Check if the last argument is a number (default index)
    if [[ "${options[-1]}" =~ ^[0-9]+$ ]]; then
        default_index="${options[-1]}"
        unset 'options[-1]'
    fi

    local num_options="${#options[@]}"
    if (( num_options == 0 )); then
        echo "No options provided to select from."
        return 1
    fi

    echo "Select an option <$var_name>:"
    for i in "${!options[@]}"; do
        echo "$((i + 1))) ${options[$i]}"
    done

    local prompt_msg="Enter the number"
    if (( default_index >= 1 && default_index <= num_options )); then
        prompt_msg+=" [Default: $default_index]"
    fi
    prompt_msg+=": "

    while true; do
        read -rp "$prompt_msg" user_input

        if [[ -z "$user_input" && "$default_index" -ge 1 && "$default_index" -le "$num_options" ]]; then
            user_input="$default_index"
            warning "No input provided. Using default option $user_input."
        fi

        if [[ "$user_input" =~ ^[1-9][0-9]*$ ]] && (( user_input >= 1 && user_input <= num_options )); then
            eval "$var_name=\"${options[$((user_input - 1))]}\""
            break
        else
            danger "Invalid selection. Enter a number between 1 and $num_options."

            if (( default_index >= 1 && default_index <= num_options )); then
                echo "Enter to accept the default option $default_index."
            fi
        fi
    done
}
