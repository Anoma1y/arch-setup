#!/bin/bash

alias vim="nvim"
alias vi="nvim"

alias gs="git status --short"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias gcma="git commit --ammend"
alias gdf="git diff"
alias gpull="git pull"
alias gpush="git push"

gpushb() {
  git push origin "$(git symbolic-ref --short HEAD)"
}

# Navigate up two directories in the file system.
alias ...="cd ../.."

# List all files in long format, including hidden files
alias ll="eza -la"

# List all files in long format, including hidden files, sorted by last modified time
alias lls="eza -la --sort=modified"

# List files in long tree format
alias llt="eza -lT"

# Clear the terminal, display system info
alias flex="clear && fastfetch"

# Display a concise and graphical git commit log with commit hash, message, relative date, and author.
alias glog="git log --graph --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%C(yellow)%d%Creset' --abbrev-commit"

# Show a short summary of contributors to the git repository, sorted by number of commits.
alias glogc="git shortlog -s -n --all"

# List all untracked files in the git repository, excluding files ignored by .gitignore.
alias gsu="git ls-files --others --exclude-standard"

# Use 256-color terminal when connecting to a remote system via SSH.
alias ssh="TERM=xterm-256color ssh"

# Set up keyboard layouts for US English and Russian, toggling with Alt+Shift.
alias keyboard="setxkbmap -option 'grp:alt_shift_toggle' -layout us,ru"
