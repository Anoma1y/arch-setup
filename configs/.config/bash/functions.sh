#!/bin/zsh

function lazyload {
  local cmd=$1
  shift
  local load_cmd="$@"

  if [[ ${funcstack[2]} == "$cmd" ]]; then
    unfunction $cmd
    eval "$load_cmd"
  else
    eval "function $cmd { lazyload $cmd ${(qqqq)load_cmd} && $cmd \"\$@\" }"
  fi
}
