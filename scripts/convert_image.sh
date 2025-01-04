#!/bin/bash

function show_help() {
    echo "Usage: $0 [-f png|jpg|webp] [--delete] <path to file or folder>"
    echo ""
    echo "Options:"
    echo "  -s, --source           Specify the source format to process (default: all). Supported: webp, jpg, png"
    echo "  -f, --format           Specify the output format (default: jpg). Supported: png, jpg, webp"
    echo "  -d, --delete           Remove the source file after conversion (default: false)"
    echo "  -h, --help             Display this help message and exit"
    echo ""
    echo "Examples:"
    echo "  $0 -f png /path/to/file.jpg"
    echo "  $0 --delete /path/to/folder"
}

function convert_file_to_format() {
    local input_file="$1"
    local format="$2"
    local remove_source="$3"

    # Extract input file extension
    local input_ext="${input_file##*.}"
    # Generate output file path by replacing extension with desired format
    local output_file="${input_file%.*}.${format}"

    # Check if source and target formats are the same
    if [[ "$input_ext" == "$format" ]]; then
        echo "Skipping file: $input_file (source and target formats are the same)"
        return
    fi

    # Convert to the specified format using ffmpeg
    if command -v ffmpeg >/dev/null 2>&1; then
        ffmpeg -i "$input_file" "$output_file" -y >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Conversion completed: $output_file"
            # Remove source file if remove_source is true
            if [ "$remove_source" == "true" ]; then
                rm "$input_file"
                echo "Source file removed: $input_file"
            fi
        else
            echo "Error converting file: $input_file"
        fi
    else
        echo "Error: ffmpeg is not installed."
        exit 1
    fi
}

function process_directory() {
    local dir_path="$1"
    local format="$2"
    local source="$3"
    local remove_source="$4"

    find "$dir_path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r file; do
        local input_ext="${file##*.}"
        if [ -n "$source" ] && [[ "$input_ext" != "$source" ]]; then
            continue
        fi
        convert_file_to_format "$file" "$format" "$remove_source"
    done
}

# Default values
source=""
format="jpg"
remove_source="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--format)
            format="$2"
            shift 2
        ;;
        -s|--source)
            source="$2"
            shift 2
        ;;
        -d|--delete)
            remove_source="true"
            shift
        ;;
        -h|--help)
            show_help
            exit 0
        ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            exit 1
        ;;
        *)
            input_path="$1"
            shift
        ;;
    esac
done

if [ -z "$input_path" ]; then
    echo "Error: No input file or folder specified."
    show_help
    exit 1
fi

if [[ "$format" != "jpg" && "$format" != "png" && "$format" != "webp" ]]; then
    echo "Error: Unsupported output format '$format'. Use 'jpg', 'png', or 'webp'."
    show_help
    exit 1
fi

if [ -n "$source" ] && [[ "$source" != "jpg" && "$source" != "png" && "$source" != "webp" ]]; then
    echo "Error: Unsupported source format '$source'. Use 'jpg', 'png', or 'webp'."
    show_help
    exit 1
fi

if [ -d "$input_path" ]; then
    process_directory "$input_path" "$format" "$source" "$remove_source"
elif [ -f "$input_path" ]; then
    input_ext="${input_path##*.}"
    if [ -z "$source" ] || [[ "$input_ext" == "$source" ]]; then
        convert_file_to_format "$input_path" "$format" "$remove_source"
    else
        echo "Skipping file: $input_path (does not match source format '$source')"
    fi
else
    echo "Error: Input must be a file or a folder."
    exit 1
fi
