#!/bin/zsh

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
echo "---" | tee -a /tmp/polybar.log

for m in $(polybar --list-monitors | cut -d":" -f1) do
    if [[ $m == 'eDP1' ]] then
	MONITOR=$m polybar main >>/tmp/polybar.log 2>&1 & disown
    elif [[ $m == 'HDMI1' ]] then
	MONITOR=$m polybar external-monitor >>/tmp/polybar.log 2>&1 & disown
    fi
done

#MONITOR=eDP1 polybar main >>/tmp/polybar.log 2>&1 & disown
#MONITOR=HDMI1 polybar external-monitor >>/tmp/polybar.log 2>&1 & disown
