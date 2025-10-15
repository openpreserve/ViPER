#!/bin/bash
# Toggle Conky system monitor on/off

if pgrep -x conky > /dev/null; then
    # Conky is running, kill it
    pkill conky
    notify-send "Conky" "System monitor hidden" -i utilities-system-monitor
else
    # Conky is not running, start it
    if [ -f /config/.conkyrc ]; then
        conky -c /config/.conkyrc > /dev/null 2>&1 &
        notify-send "Conky" "System monitor shown" -i utilities-system-monitor
    else
        notify-send "Conky" "Config file not found" -i dialog-error
    fi
fi
