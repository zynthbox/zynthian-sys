#!/bin/bash

# Check if zynthbox-z2.txt file is present in boot dir
# If file is present, install z2 config and restart device
if [ -e /boot/zynthbox-z2.txt ]; then
	if [ -e /zynthian/zynthian-sys/boot/zynthbox-z2-setup*.deb ]; then
		dpkg -i /zynthian/zynthian-sys/boot/zynthbox-z2-setup*.deb
		rm /zynthian/zynthian-sys/boot/zynthbox-z2-setup*.deb
		reboot
	fi
fi

# Load Config Envars
source "/zynthian/config/zynthian_envars.sh"

# Rotate display if XRANDR_ROTATE var is set
if [ -z ${XRANDR_ROTATE} ]; then
	echo "not rotating"
else
	xrandr -o $XRANDR_ROTATE
fi

# Throw up a splash screen while we do the firstboot setup
if [ ! -p /tmp/mplayer-firstboot-splash-control ]; then
	mkfifo /tmp/mplayer-firstboot-splash-control
fi

mplayer -slave -input file=/tmp/mplayer-firstboot-splash-control -noborder -ontop "mf:///usr/share/zynthbox-bootsplash/zynthbox-firstboot.jpg" -loop 0 &> /dev/null &

# Get System Codebase
codebase=`lsb_release -cs`

# Regenerate Keys
$ZYNTHIAN_SYS_DIR/sbin/regenerate_keys.sh

# Enable WIFI AutoAccessPoint (hostapd)
systemctl unmask hostapd

#Regenerate cache LV2
cd $ZYNTHIAN_CONFIG_DIR/jalv
if [[ "$(ls -1q | wc -l)" -lt 20 ]]; then
	echo "Regenerating cache LV2 ..."
	cd $ZYNTHIAN_UI_DIR/zyngine
	python3 ./zynthian_lv2.py
fi

# Run distro-specific script
cd $ZYNTHIAN_SYS_DIR/scripts
if [ -f "first_boot.$codebase.sh" ]; then
	./first_boot.$codebase.sh
fi

# Disable first_boot service
systemctl disable first_boot

# Enable splash-screen
systemctl enable splash-screen

# Resize partition
$ZYNTHIAN_SYS_DIR/scripts/rpi-wiggle.sh
