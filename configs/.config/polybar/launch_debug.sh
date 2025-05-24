#!/bin/bash

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

NAME="desktop"

if [ "$1" = "laptop" ]; then
	NAME="laptop"
fi

PRIMARY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)

for m in $(polybar --list-monitors | cut -d":" -f1); do
    if [[ "$m" == "$PRIMARY" ]]; then
        (MONITOR=$m polybar --reload "$NAME" ; echo $? >> ~/.config/polybar/debug.log) &
    else
        MONITOR=$m polybar --reload secondary &
    fi
done
