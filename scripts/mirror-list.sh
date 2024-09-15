#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/functions/functions.sh"

REGION="RU"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --region=*)
            REGION="${1#*=}"
            ;;
        --region)
            shift
            if [[ "$#" -gt 0 ]]; then
                REGION="$1"
            else
                echo "Error: --region option requires an argument."
                exit 1
            fi
            ;;
    esac
    shift
done

mirrorlist_update "$REGION"
