#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar
echo "---" | tee -a /tmp/polybar.log

#for m in $(polybar --list-monitors | cut -d":" -f1); do
#    MONITOR=$m polybar example >>/tmp/polybar.log 2>&1 & disown
#done

MONITOR=eDP1 polybar example >>/tmp/polybar.log 2>&1 & disown
MONITOR=HDMI1 polybar example2 >>/tmp/polybar.log 2>&1 & disown
