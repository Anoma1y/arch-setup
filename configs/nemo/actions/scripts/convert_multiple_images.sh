#!/bin/bash

replace="no" # "yes" or "no"

while [[ "$1" == --* ]]; do
    case "$1" in
        --replace)
            replace="${2:-no}"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

if [ "$#" -eq 0 ]; then
    echo "Error: No files selected."
    echo "Usage: $0 [--replace yes|no] file1 file2 ..."
    exit 1
fi

for file in "$@"; do
    if [[ "$replace" == "yes" ]]; then
        convert_image "$file" -f jpg -d
    else
        convert_image "$file" -f jpg
    fi
done
