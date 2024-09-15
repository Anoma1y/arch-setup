#!/bin/bash

# Navigate up two directories in the file system.
alias ...="cd ../.."

# List all files and directories (including hidden ones) with detailed info, appending / to directories.
alias ll="ls -laF"

# List all files and directories ordered by modification time, with newest files at the end.
alias lls="ls -laFtr"

# Show a brief summary of the current git status (modified, added, deleted files).
alias gs="git status --short"

# Display full git status, including untracked and staged files.
alias gsf="git status"

# Clear the terminal, display system info (with CPU details and temperature)
alias flex="clear && fastfetch"

# Show the differences between the working directory and the latest commit or staging area.
alias gdiff="git diff"

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