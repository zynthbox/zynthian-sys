#!/bin/bash

# Hardware Autoconfig
echo -e "### FIRST BOOT SETUP : $(date)\n" >> /root/first_boot.log
echo -e "\nRunning autoconfig..." >> /root/first_boot.log
$ZYNTHIAN_SYS_DIR/sbin/zynthian_autoconfig.py 2>&1 >> /root/first_boot.log

# Load Config Envars
echo -e "\nLoading config envars" >> /root/first_boot.log
source "/zynthian/config/zynthian_envars.sh"

rotation=$(echo $DISPLAY_KERNEL_OPTIONS | grep -oP "(?<=rotate=)(\d*)")
if [ $rotation -eq "180" ]; then
    echo -e "\nConfiguration says display is inverted. Since new cmdline is not yet in effect during firstboot, rotate with xrandr" >> /root/first_boot.log
    xrandr -o inverted
fi

mplayer -slave -noborder -ontop "mf:///usr/share/zynthbox-bootsplash/zynthbox-firstboot.jpg" -loop 0 &> /dev/null &

# Run update_zynthian_sys to generate config based on selected device
echo -e "\nRunning update_zynthian_sys.sh" >> /root/first_boot.log
$ZYNTHIAN_SYS_DIR/scripts/update_zynthian_sys.sh 2>&1 >> /root/first_boot.log

# Fix ALSA mixer settings
echo -e "\nFixing ALSA mixer settings..." >> /root/first_boot.log
$ZYNTHIAN_SYS_DIR/sbin/fix_alsamixer_settings.sh 2>&1 >> /root/first_boot.log

# Regenerate Keys
echo -e "\nRegenerating keys..." >> /root/first_boot.log
$ZYNTHIAN_SYS_DIR/sbin/regenerate_keys.sh 2>&1 >> /root/first_boot.log

# Enable WIFI AutoAccessPoint (hostapd)
echo -e "\nUnmasking WIFI access point service..." >> /root/first_boot.log
systemctl unmask hostapd

#Regenerate cache LV2
cd $ZYNTHIAN_CONFIG_DIR/jalv
if [[ "$(ls -1q | wc -l)" -lt 20 ]]; then
    echo "Regenerating cache LV2 ..." >> /root/first_boot.log
    cd $ZYNTHIAN_UI_DIR/zyngine
    python3 ./zynthian_lv2.py
fi

# Disable first_boot service
systemctl disable first_boot

# Enable splash-screen
systemctl enable splash-screen

# Resize partition & reboot
echo -e "Resizing partition..." >> /root/first_boot.log
raspi-config --expand-rootfs

# Reboot
reboot
