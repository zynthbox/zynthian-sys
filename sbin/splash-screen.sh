#!/bin/bash
 
# Source config
if [ -d "$ZYNTHIAN_CONFIG_DIR" ]; then
	source "$ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh"
else
	source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars.sh"
fi

# Display Zynthbox Boot Splash Screen
if [ -c $FRAMEBUFFER ]; then
	cat /usr/share/zynthbox-bootsplash/boot-splash.raw > $FRAMEBUFFER
fi
