#!/bin/bash

function reset_branch() {
  local target_branch="develop"
  local base_branch="master"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch|-b)
        target_branch="$2"
        shift 2
        ;;
      --base|-m)
        base_branch="$2"
        shift 2
        ;;
      --help|-h)
        echo "Usage: reset_branch [--branch <target-branch>] [--base <base-branch>]"
        echo
        echo "Defaults:"
        echo "  --branch (-b): develop"
        echo "  --base (-m): master"
        return 0
        ;;
      *)
        echo "Unknown argument: $1"
        echo "Use --help for usage information."
        return 1
        ;;
    esac
  done

  git checkout "$base_branch" && \
  git branch -D "$target_branch" && \
  git fetch origin "$target_branch" && \
  git checkout -b "$target_branch" "origin/$target_branch"
}

