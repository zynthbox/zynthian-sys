#!/bin/bash

#-----------------------------------------------------------------------------------------------------
# This script is invoked by the check_kit_version service on every boot after the first_boot service.
# 1. During first boot, first boot will call the update_zynthian_sys.sh 
#    which will write the kit version in the config. After first_boot service reboots the system,
#    this script is called and ideally does nothing since kit version is not changed.
# 2. When the system is updated from the UI, the update_zynthian_sys.sh is called, 
#    kit version stored in config and the system is rebooted.
# 3. During reboots, if the kit changes, then this script is called which detects change in kit version 
#    from the last version, calls the update_zynthian_sys.sh and applies the kit specific variables 
#    and also stores the udpated kit version in config. 
#-----------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Load Environment Variables
#------------------------------------------------------------------------------

if [ -z "$ZYNTHIAN_CONFIG_DIR" -o -z "$ZYNTHIAN_SYS_DIR" ]; then
	export ZYNTHIAN_CONFIG_DIR="/zynthian/config"
	export ZYNTHIAN_SYS_DIR="/zynthian/zynthian-sys"
fi

source "$ZYNTHIAN_SYS_DIR/config/zynthian_envars.sh"

# Check if kit version changed from last boot.
KIT_VERSION_FILE="$ZYNTHIAN_CONFIG_DIR/.kit_version"
SAVED_KIT_VERSION=$(cat "$KIT_VERSION_FILE" | tr -d '\n')

if [[ ! -f "$KIT_VERSION_FILE" ]]; then

    echo "Kit version file not found. Assuming first-time setup." | systemd-cat -t check_kit_version -p info
    echo "Kit version changed from last boot (none) -> $DETECTED_KIT" | systemd-cat -t check_kit_version -p info

    RUN_UPDATE_ZYNTHIAN_SYS=true
elif [[ "$SAVED_KIT_VERSION" != "$ZYNTHIAN_KIT_VERSION" ]]; then

    echo "Kit version changed from last boot $(cat "$KIT_VERSION_FILE") -> $DETECTED_KIT" | systemd-cat -t check_kit_version -p info

    RUN_UPDATE_ZYNTHIAN_SYS=true
else
    echo "Kit version same as previous version after reboot. No action needed." | systemd-cat -t check_kit_version -p info
fi

if [[ $RUN_UPDATE_ZYNTHIAN_SYS == true ]]; then
    echo "Running udapte zynthian sys & rebooting system to apply changes" | systemd-cat -t check_kit_version -p info

    # Run the zynthian update script
    /zynthian/zynthian-sys/scripts/update_zynthian_sys.sh

    # Reboot the system so that the changes are applied
    reboot

fi