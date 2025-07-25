#!/bin/bash
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+?(?=%)' | head -1)

if [ "$volume" -gt 0 ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -10%
fi
