#!/bin/bash

set -e

DOWNLOAD_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
TEMP_DIR="/tmp"
DOWNLOAD_FILE="$TEMP_DIR/discord.tar.gz"
INSTALL_DIR="$HOME/Programs/Discord"

function echo_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

function echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

if command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget -L \"$DOWNLOAD_URL\" -O \"$DOWNLOAD_FILE\""
elif command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl -L \"$DOWNLOAD_URL\" -o \"$DOWNLOAD_FILE\""
else
    echo_error "Neither wget nor curl is installed. Please install one to proceed."
    exit 1
fi

echo_info "Downloading the latest version of Discord..."
eval $DOWNLOADER

if [ ! -f "$DOWNLOAD_FILE" ]; then
    echo_error "Download failed. The file $DOWNLOAD_FILE does not exist."
    exit 1
fi

echo_info "Download completed successfully."

if [ -d "$INSTALL_DIR" ]; then
    echo_info "Removing the old Discord installation at $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    echo_info "Old Discord installation removed."
else
    echo_info "No existing Discord installation found at $INSTALL_DIR."
fi

echo_info "Creating installation directory at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

echo_info "Extracting Discord to $INSTALL_DIR..."
tar -xzf "$DOWNLOAD_FILE" -C "$INSTALL_DIR" --strip-components=1

echo_info "Extraction completed successfully."

echo_info "Removing the downloaded archive..."
rm "$DOWNLOAD_FILE"

echo_info "Discord has been successfully updated to the latest version."

exit 0
