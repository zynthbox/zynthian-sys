#!/bin/bash
 
# Source config
source "$ZYNTHIAN_SYS_DIR/config/zynthian_envars.sh"

# Display Zynthbox Boot Splash Screen
if [ -c $FRAMEBUFFER ]; then
	if [ "$XRANDR_ROTATE" = "inverted" ]; then
		cat /usr/share/zynthbox-bootsplash/boot-splash-inverted.raw > $FRAMEBUFFER
	else
		cat /usr/share/zynthbox-bootsplash/boot-splash.raw > $FRAMEBUFFER
	fi
fi
