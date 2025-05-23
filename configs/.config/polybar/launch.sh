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
        MONITOR=$m polybar "$NAME" &
    else
        MONITOR=$m polybar secondary &
    fi
done
