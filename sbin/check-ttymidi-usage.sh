#!/bin/bash

# This script checks the CPU usage of ttymidi process
# If CPU usage is above 15% then the service is restarted
# This script will be invoked by a systemd timer every 15 mins 

###
# Return integer part of a floating point number
# $1 : Floating point number
###
to_int() {
  echo "$1" | cut -d "." -f 1
}

ttymidi_pid=$(systemctl show --property MainPID --value mod-ttymidi.service)
ttymidi_usage=$(top -b -p $ttymidi_pid -n 1 | tail -n 1 | awk '{print $9}')

echo "ttymidi (pid #$ttymidi_pid) CPU Usage : $ttymidi_usage"

if [ $(to_int $ttymidi_usage) -gt 15 ]; then
  echo "ttymidi CPU Usage is > 15. Restarting mod-ttymidi.service"
  systemctl restart mod-ttymidi.service
fi
