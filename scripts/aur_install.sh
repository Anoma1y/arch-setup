#!/bin/bash

USER_NAME=$(whoami)
COMMAND="yay"

aur_command_install "$USER_NAME" "$COMMAND"
