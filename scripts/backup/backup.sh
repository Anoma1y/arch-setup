#!/bin/bash

set -e

CONFIG_FILE="backup_config.yml"

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
  local source_dir="$1"
  local dest_dir="$2"

  mkdir -p "$dest_dir"

  rsync -avh --delete "$source_dir/" "$dest_dir/"

  echo "Backup of '$source_dir' to '$dest_dir' completed successfully."
}

function main() {
  check_dependencies

  target=$(yq e '.target' "$CONFIG_FILE")
  target=$(expand_path "$target")

  if [ ! -d "$target" ]; then
    echo "Target directory '$target' does not exist. Ensure it's mounted."
    exit 1
  fi

  sources_length=$(yq e '.sources | length' "$CONFIG_FILE")

  for (( i=0; i<sources_length; i++ )); do
    source=$(yq e ".sources[$i].source" "$CONFIG_FILE")
    destination=$(yq e ".sources[$i].destination" "$CONFIG_FILE")

    source=$(expand_path "$source")

    full_destination="$target$destination"

    if [ ! -d "$source" ]; then
      echo "Source directory '$source' does not exist. Skipping."
      continue
    fi

    perform_backup "$source" "$full_destination"
  done

  echo "All backups completed."
}

main
