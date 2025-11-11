#!/bin/bash

TARGET_DIR="."
SOURCE_PROVIDED=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --source)
            if [ -z "$2" ]; then
                echo "Error: The --source option requires a path argument (source directory)." >&2
                exit 1
            fi
            TARGET_DIR="$2"
            SOURCE_PROVIDED=1
            shift
            ;;
        --sort-by)
            if [ -z "$2" ]; then
                echo "Error: The --sort-by option requires an argument (month|day)." >&2
                exit 1
            fi
            SORT_BY="$2"
            if [[ "$SORT_BY" != "month" && "$SORT_BY" != "day" ]]; then
                echo "Error: Invalid argument for --sort-by. Use 'month' or 'day'." >&2
                exit 1
            fi
            shift
            ;;
        *)
            echo "Error: Unknown option '$1'. Usage: $0 [--source /path/to/folder] [--sort-by month|day]" >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$SOURCE_PROVIDED" -eq 1 ]; then
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Error: Source directory '$TARGET_DIR' not found or is not a directory." >&2
        exit 1
    fi
fi

echo "Starting file organization in directory: $(pwd)/$TARGET_DIR"
echo "Files will be sorted by their last modification date."
echo "---"

shopt -s nullglob

for file in "$TARGET_DIR"/*; do
    if [[ -f "$file" ]]; then
        FILENAME=$(basename "$file")

        if [[ "$FILENAME" == "$(basename "$0")" && "$(dirname "$file")" == "$TARGET_DIR" ]]; then
            continue
        fi

        MOD_TIMESTAMP=$(stat -c "%y" "$file" 2>/dev/null)
        
        if [[ -z "$MOD_TIMESTAMP" ]]; then
            echo "⚠️ Skipping '$FILENAME': Could not retrieve modification timestamp (GNU stat failed)."
            continue
        fi

        if [[ "$SORT_BY" == "month" ]]; then
            FOLDER_NAME=$(LC_ALL=C date -d "$MOD_TIMESTAMP" +%Y-%m)
        else
            FOLDER_NAME=$(LC_ALL=C date -d "$MOD_TIMESTAMP" +%Y-%m-%d)
        fi

        DEST_DIR="$TARGET_DIR/$FOLDER_NAME"

        if [[ ! -d "$DEST_DIR" ]]; then
            echo "📁 Creating directory: $FOLDER_NAME (inside $TARGET_DIR)"
            mkdir -p "$DEST_DIR"
        fi

        echo "➡️ Moving '$FILENAME' to '$FOLDER_NAME/'"
        mv "$file" "$DEST_DIR/"
    fi
done

shopt -u nullglob

echo "---"
echo "✅ Organization complete."
