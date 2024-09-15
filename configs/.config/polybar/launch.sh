#!/bin/bash

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

if [ "$1" = "laptop" ]; then
    polybar laptop &
else
    polybar desktop &
fi
