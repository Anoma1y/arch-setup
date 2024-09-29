#!/bin/bash

function lazyload {
  local seperator='--'
  local seperator_index=${@[(ie)$seperator]}
  local cmd_list=(${@:1:(($seperator_index - 1))});
  local load_cmd=${@[(($seperator_index + 1))]};

  if [[ ! $load_cmd ]]; then
    >&2 echo "[ERROR] command_lazyload: No load command defined"
    >&2 echo "  $@"
    return 1
  fi

  if (( ${cmd_list[(Ie)${funcstack[2]}]} )); then
    unfunction $cmd_list
    eval "$load_cmd"
  else
    local cmd
    for cmd in $cmd_list; eval "function $cmd { lazyload $cmd_list $seperator ${(qqqq)load_cmd} && $cmd \"\$@\" }"
  fi
}

function command_lazyload {
  local separator='--'
  local separator_index
  local i

  # Find the index of the separator '--'
  for ((i=1; i<=$#; i++)); do
    if [ "${!i}" == "$separator" ]; then
      separator_index=$i
      break
    fi
  done

  if [ -z "$separator_index" ]; then
    echo "[ERROR] command_lazyload: Separator '--' not found in arguments" >&2
    echo "  $@" >&2
    return 1
  fi

  # Extract command list and load command
  local cmd_list=("${@:1:$((separator_index - 1))}")
  local load_cmd=("${@:$((separator_index + 1))}")

  if [ ${#load_cmd[@]} -eq 0 ]; then
    echo "[ERROR] command_lazyload: No load command defined" >&2
    echo "  $@" >&2
    return 1
  fi

  # Get the name of the calling function
  local caller="${FUNCNAME[1]}"

  # Check if the calling function is in the command list
  local found=false
  for cmd in "${cmd_list[@]}"; do
    if [ "$cmd" == "$caller" ]; then
      found=true
      break
    fi
  done

  if [ "$found" = true ]; then
    # Unset the functions and execute the load command
    unset -f "${cmd_list[@]}"
    eval "${load_cmd[@]}"
  else
    # Define lazy-loaded functions for each command
    local cmd
    for cmd in "${cmd_list[@]}"; do
      eval "function $cmd {
        command_lazyload \"${cmd_list[@]}\" $separator \"${load_cmd[@]}\"
        $cmd \"\$@\"
      }"
    done
  fi
}

