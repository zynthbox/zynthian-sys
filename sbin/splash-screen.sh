#!/bin/bash

# Source config
if [ -d "$ZYNTHIAN_CONFIG_DIR" ]; then
	source "$ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh"
else
	source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars.sh"
fi

# Rotate display if required
if [ -z ${XRANDR_ROTATE} ]; then
	# Display Zynthian Boot Splash Screen
	if [ -c $FRAMEBUFFER ]; then
		cat /usr/share/zynthbox-bootsplash/zynthbox.raw > $FRAMEBUFFER
	fi  
else
	# Display Zynthian Boot Splash Screen - Inverted
	if [ -c $FRAMEBUFFER ]; then
		cat /usr/share/zynthbox-bootsplash/zynthbox-inverted.raw > $FRAMEBUFFER
	fi  
fi
