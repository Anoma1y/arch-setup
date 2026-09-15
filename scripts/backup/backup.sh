#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/backup_config.yml"

function check_dependencies() {
  if ! command -v yq &> /dev/null
  then
    echo "\"yq\" could not be found."
    exit 1
  fi

  if ! command -v rsync &> /dev/null
  then
    echo "\"rsync\" could not be found."
    exit 1
  fi
}

function expand_path() {
  echo "$1" | sed "s|~|$HOME|g"
}

function perform_backup() {
  local source="$1"
  local dest="$2"

  if [ -d "$source" ]; then
    mkdir -p "$dest"
    # Trailing slashes: sync folder contents; --delete mirrors removals
    rsync -avh --delete "${source}/" "${dest}/"
  elif [ -f "$source" ]; then
    mkdir -p "$(dirname "$dest")"
    rsync -avh "$source" "$dest"
  else
    echo "Source '$source' does not exist. Skipping."
    return 0
  fi

  echo "Backup of '$source' to '$dest' completed successfully."
}

function main() {
  check_dependencies

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file '$CONFIG_FILE' not found. Copy backup_config.yml.example to backup_config.yml."
    exit 1
  fi

  target=$(yq e '.target' "$CONFIG_FILE")
  target=$(expand_path "$target")

  if [ ! -d "$target" ]; then
    echo "Target directory '$target' does not exist. Ensure it's mounted."
    exit 1
  fi

  sources_length=$(yq e '.sources | length' "$CONFIG_FILE")

  for (( i=0; i<sources_length; i++ )); do
    source=$(yq e ".sources[$i].source" "$CONFIG_FILE")
    destination=$(yq e ".sources[$i].destination // \"\"" "$CONFIG_FILE")

    source=$(expand_path "$source")

    if [ -z "$destination" ] || [ "$destination" = "null" ]; then
      destination="/$(basename "$source")"
    fi

    full_destination="$target$destination"

    perform_backup "$source" "$full_destination"
  done

  echo "All backups completed."
}

main
