#!/bin/sh

# $1 is the action (start, stop, restart, etc.)
# $2 is the service name

if [ "$2" = "fluidsynth" ]; then
    echo "Blocking service action for fluidsynth"
    exit 101   # 101 = "action forbidden"
fi

# Allow all other services
exit 0
