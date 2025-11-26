#!/bin/bash

# Set default NVM directory if not already defined
[[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

# Check if a command exists
zsh_nvm_has() {
  type "$1" > /dev/null 2>&1
}

# List all globally installed node binaries
zsh_nvm_global_binaries() {
  local binary_paths="$(echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N))"

  if [[ -n "$binary_paths" ]]; then
    echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N) |
      xargs -n 1 basename |
      sort |
      uniq
  fi
}

# Load nvm by sourcing its main script
zsh_nvm_load() {
  source "$NVM_DIR/nvm.sh"
}

# Set up lazy loading for nvm and node binaries
zsh_nvm_lazy_load() {
  # Collect all global node module binaries
  local binaries
  binaries=($(zsh_nvm_global_binaries))

  # Include yarn if installed outside npm
  zsh_nvm_has yarn && binaries+=('yarn')

  # Include nvm itself and any extra commands
  binaries+=('nvm')
  binaries+=($NVM_LAZY_LOAD_EXTRA_COMMANDS)

  # Filter out binaries that are aliased
  local commands
  commands=()
  local binary
  for binary in $binaries; do
    [[ "$(which $binary 2> /dev/null)" = "$binary: aliased to "* ]] || commands+=($binary)
  done

  # Create lazy loader stub functions
  local command
  for command in $commands; do
    # On first call, remove stubs, load nvm, then execute actual command
    eval "$command(){
      unset -f $commands > /dev/null 2>&1
      zsh_nvm_load
      $command \"\$@\"
    }"
  done
}

if [[ -f "$NVM_DIR/nvm.sh" ]]; then
    zsh_nvm_lazy_load || zsh_nvm_load
    [[ -r $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion
fi

