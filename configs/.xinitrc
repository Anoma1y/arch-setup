#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

exec i3
