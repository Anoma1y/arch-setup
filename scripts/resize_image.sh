#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <image_file> <size>"
    echo "Examples:"
    echo "  $0 image.jpg 300x200    # Resize to specific width and height"
    echo "  $0 image.jpg 300        # Resize with maximum dimension (maintains aspect ratio)"
    exit 1
fi

IMAGE_FILE="$1"
SIZE="$2"

if ! command -v magick &>/dev/null; then
    echo "Error: imagemagick is not installed."
    exit 1
fi

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: File $IMAGE_FILE does not exist."
    exit 1
fi

BASENAME=$(basename "$IMAGE_FILE")
EXTENSION="${BASENAME##*.}"
NAME="${BASENAME%.*}"
OUTPUT_PATH="$(dirname "$IMAGE_FILE")/${NAME}_${SIZE}.${EXTENSION}"

function get_resize_option() {
    local input_size="$1"
    if [[ "$input_size" =~ ^[0-9]+x[0-9]+$ ]]; then
        echo "$input_size"
    elif [[ "$input_size" =~ ^[0-9]+$ ]]; then
        local dimension="$input_size"
        local dimensions=$(identify -format "%w %h" "$IMAGE_FILE")
        local width=$(echo "$dimensions" | awk '{print $1}')
        local height=$(echo "$dimensions" | awk '{print $2}')
        if [ "$width" -ge "$height" ]; then
            echo "$dimension"x"$(($dimension * $height / $width))"
        else
            echo "$(($dimension * $width / $height))"x"$dimension"
        fi
    else
        echo "Error: Invalid size format. Use WxH or S."
        exit 1
    fi
}

RESIZE_OPTION=$(get_resize_option "$SIZE")

magick "$IMAGE_FILE" -resize "$RESIZE_OPTION" "$OUTPUT_PATH"
