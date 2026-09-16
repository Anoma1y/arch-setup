#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/backup_config.json"

function check_dependencies() {
  if ! command -v jq &> /dev/null
  then
    echo "\"jq\" could not be found."
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

# Join target + destination safely: ".claude" and "/.claude" both -> "$target/.claude"
function join_dest() {
  local target="$1"
  local destination="$2"
  echo "${target%/}/${destination#/}"
}

# Reads exclude patterns from jq into a bash array of --exclude=... args.
# Usage: build_exclude_args out_array_name <jq-expression>
function build_exclude_args() {
  local -n _exclude_args=$1
  local jq_expr="$2"
  local patterns=()
  local pattern

  _exclude_args=()
  mapfile -t patterns < <(jq -r "$jq_expr" "$CONFIG_FILE")
  for pattern in "${patterns[@]}"; do
    [[ -z "$pattern" ]] && continue
    _exclude_args+=(--exclude="$pattern")
  done
}

function perform_backup() {
  local source="$1"
  local dest="$2"
  shift 2
  local exclude_args=("$@")

  if [ -d "$source" ]; then
    mkdir -p "$dest"
    # Trailing slashes: sync folder contents; --delete mirrors removals
    rsync -avh --delete "${exclude_args[@]}" "${source}/" "${dest}/"
  elif [ -f "$source" ]; then
    mkdir -p "$(dirname "$dest")"
    rsync -avh "${exclude_args[@]}" "$source" "$dest"
  else
    echo "Source '$source' does not exist. Skipping."
    return 0
  fi

  echo "Backup of '$source' to '$dest' completed successfully."
}

# Resolve a source path using optional base, or parent of first absolute path in the list.
function resolve_source_path() {
  local path="$1"
  local base="$2"
  local fallback_base="$3"

  path=$(expand_path "$path")

  if [[ "$path" == /* ]]; then
    echo "$path"
    return
  fi

  if [[ -n "$base" ]]; then
    echo "${base%/}/$path"
    return
  fi

  if [[ -n "$fallback_base" ]]; then
    echo "${fallback_base%/}/$path"
    return
  fi

  echo "$path"
}

function main() {
  check_dependencies

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file '$CONFIG_FILE' not found. Copy backup_config.json.example to backup_config.json."
    exit 1
  fi

  target=$(jq -r '.target' "$CONFIG_FILE")
  target=$(expand_path "$target")

  if [ ! -d "$target" ]; then
    echo "Target directory '$target' does not exist. Ensure it's mounted."
    exit 1
  fi

  local global_excludes=()
  build_exclude_args global_excludes '.exclude // [] | .[]'

  sources_length=$(jq -r '.sources | length' "$CONFIG_FILE")

  for (( i=0; i<sources_length; i++ )); do
    local destination base source_type
    local raw_sources=()
    local resolved_sources=()
    local exclude_args=()
    local source_excludes=()
    local fallback_base=""
    local path resolved dest_path name

    destination=$(jq -r ".sources[$i].destination // \"\"" "$CONFIG_FILE")
    base=$(jq -r ".sources[$i].base // \"\"" "$CONFIG_FILE")
    [[ "$base" == "null" ]] && base=""
    [[ -n "$base" ]] && base=$(expand_path "$base")

    source_type=$(jq -r ".sources[$i].source | type" "$CONFIG_FILE")

    if [[ "$source_type" == "array" ]]; then
      mapfile -t raw_sources < <(jq -r ".sources[$i].source[]" "$CONFIG_FILE")
    else
      raw_sources=("$(jq -r ".sources[$i].source" "$CONFIG_FILE")")
    fi

    # First absolute path's parent is used to resolve relative entries (e.g. "skills")
    for path in "${raw_sources[@]}"; do
      path=$(expand_path "$path")
      if [[ "$path" == /* ]]; then
        fallback_base="$(dirname "$path")"
        break
      fi
    done

    resolved_sources=()
    for path in "${raw_sources[@]}"; do
      resolved=$(resolve_source_path "$path" "$base" "$fallback_base")
      resolved_sources+=("$resolved")
    done

    if [ -z "$destination" ] || [ "$destination" = "null" ]; then
      if [[ -n "$base" ]]; then
        destination="$(basename "$base")"
      elif [[ "${#resolved_sources[@]}" -eq 1 ]]; then
        destination="$(basename "${resolved_sources[0]}")"
      elif [[ -n "$fallback_base" ]]; then
        destination="$(basename "$fallback_base")"
      else
        echo "Error: destination is required when source is an array without a common base."
        exit 1
      fi
    fi

    build_exclude_args source_excludes ".sources[$i].exclude // [] | .[]"
    exclude_args=("${global_excludes[@]}" "${source_excludes[@]}")

    dest_path=$(join_dest "$target" "$destination")

    if [[ "${#resolved_sources[@]}" -eq 1 && "$source_type" != "array" ]]; then
      # Single string source: keep previous semantics (folder mirrors into dest)
      perform_backup "${resolved_sources[0]}" "$dest_path" "${exclude_args[@]}"
    else
      # Array (or multi): each item lands under destination by its basename
      mkdir -p "$dest_path"
      for resolved in "${resolved_sources[@]}"; do
        name="$(basename "$resolved")"
        perform_backup "$resolved" "$dest_path/$name" "${exclude_args[@]}"
      done
    fi
  done

  echo "All backups completed."
}

main
