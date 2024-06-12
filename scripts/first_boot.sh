#!/bin/bash

# Hardware Autoconfig
echo -e "\nRunning autoconfig..." >> /root/first_boot.log
$ZYNTHIAN_SYS_DIR/sbin/zynthian_autoconfig.py 2>&1 >> /root/first_boot.log
if [ -f $REBOOT_FLAGFILE ]; then
    clean_all_flags
    echo -e "\nReboot..." >> /root/first_boot.log
    sync
    reboot -f
    exit
fi

# Load Config Envars
source "/zynthian/config/zynthian_envars.sh"

rotation=$(echo $DISPLAY_KERNEL_OPTIONS | grep -oP "(?<=rotate=)(\d*)")
if [ rotation == 180 ]; then
    # Configuration says display is inverted. Since new cmdling is not yet in effect, rotate with xrander when doing firstboot
    xrandr -o inverted
fi

mplayer -slave -noborder -ontop "mf:///usr/share/zynthbox-bootsplash/zynthbox-firstboot.jpg" -loop 0 &> /dev/null &

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
