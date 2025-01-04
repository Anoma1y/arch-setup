#!/bin/bash

set -e

TEMP_DIR="/tmp"

BASE_DIR="$HOME/Programs"
TEMP_DIR="/tmp"

DOWNLOAD_URL=""
EXECUTABLE_FILEPATH=""
TARGET_DIR=""
COMMAND_NAME=""
DOWNLOAD_FILE=""

function echo_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

function echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

function format_target_dir() {
    echo "$BASE_DIR/$1"
}

case $1 in
    "discord")
        DOWNLOAD_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
        TARGET_DIR=$(format_target_dir "Discord")
        EXECUTABLE_FILEPATH="$TARGET_DIR/Discord"
        COMMAND_NAME="discord"
        DOWNLOAD_FILE="$TEMP_DIR/discord.tar.gz"
    ;;
    "vscode")
        DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
        TARGET_DIR=$(format_target_dir "VSCode")
        EXECUTABLE_FILEPATH="$TARGET_DIR/code"
        COMMAND_NAME="code"
        DOWNLOAD_FILE="$TEMP_DIR/vscode.tar.gz"
    ;;
    *)
        echo_error "Program '$1' is not recognized"
        exit 0
    ;;
esac

echo "$TARGET_DIR"

if command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget -L \"$DOWNLOAD_URL\" -O \"$DOWNLOAD_FILE\""
elif command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl -L \"$DOWNLOAD_URL\" -o \"$DOWNLOAD_FILE\""
else
    echo_error "Neither wget nor curl is installed."
    exit 1
fi

echo_info "Downloading the latest version of $COMMAND_NAME..."
eval "$DOWNLOADER"

if [ ! -f "$DOWNLOAD_FILE" ]; then
    echo_error "Download failed. The file $DOWNLOAD_FILE does not exist."
    exit 1
fi

echo_info "Download completed successfully."

if [ -d "$TARGET_DIR" ]; then
    echo_info "Removing the old $COMMAND_NAME installation at $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
    echo_info "Old $COMMAND_NAME installation removed."
else
    echo_info "No existing $COMMAND_NAME installation found at $TARGET_DIR."
fi

echo_info "Creating installation directory at $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

echo_info "Extracting $COMMAND_NAME to $TARGET_DIR..."
tar -xzf "$DOWNLOAD_FILE" -C "$TARGET_DIR" --strip-components=1

echo_info "Extraction completed successfully."

echo_info "Removing the downloaded archive..."
rm "$DOWNLOAD_FILE"

if [[ $EXECUTABLE_FILEPATH != "" ]]; then
    echo_info "Creating symlink for $COMMAND_NAME"

    BIN_DIR="$HOME/.local/bin"
    if [[ ! -d "$BIN_DIR" ]]; then
        mkdir -p "$BIN_DIR"
    fi

    ln -sf "$EXECUTABLE_FILEPATH" "$HOME/.local/bin/$COMMAND_NAME"
fi

echo_info "$COMMAND_NAME has been successfully updated to the latest version."

exit 0
