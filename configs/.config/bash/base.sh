#!/bin/bash

# Add custom directories to the PATH for prioritizing binaries.
## Add user's custom binaries to PATH
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Set locale variables to ensure proper encoding and language settings.
## Set the entire system's locale to UTF-8.
export LC_ALL=en_US.UTF-8
## Set language preferences to US English in UTF-8 encoding.
export LANG=en_US.UTF-8
