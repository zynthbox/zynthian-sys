#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian System Configuration
# 
# Configure the system for Zynthian: copy files, create directories, 
# replace values, ...
# 
# Copyright (C) 2015-2017 Fernando Moyano <jofemodo@zynthian.org>
#
#******************************************************************************
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# For a full copy of the GNU General Public License see the LICENSE.txt file.
# ****************************************************************************

set -x

export DEBIAN_FRONTEND=noninteractive

#------------------------------------------------------------------------------
# Get System Codebase
#------------------------------------------------------------------------------

ZYNTHIAN_OS_CODEBASE=`lsb_release -cs`

#------------------------------------------------------------------------------
# Load Environment Variables
#------------------------------------------------------------------------------

if [ -z "$ZYNTHIAN_CONFIG_DIR" -o -z "$ZYNTHIAN_SYS_DIR" ]; then
	export ZYNTHIAN_CONFIG_DIR="/zynthian/config"
	export ZYNTHIAN_SYS_DIR="/zynthian/zynthian-sys"
fi

source "$ZYNTHIAN_SYS_DIR/config/zynthian_envars.sh"

#------------------------------------------------------------------------------

echo "Updating System configuration ..."

#------------------------------------------------------------------------------
# Define some functions
#------------------------------------------------------------------------------

function custom_config {
	echo "Custom Config $1 ..."
	cd "$1"
	if [ -d "etc" ]; then
		for file in etc/* ; do
			if [ "$file" = "etc/modules" ]; then
				cat "$file" >> /etc/modules
			else
				cp -a "$file" /etc
			fi
		done
	fi
	if [ -d "boot" ]; then
		for file in boot/overlays/*.dtbo ; do
			cp -a "$file" /boot/firmware/overlays
		done
		for file in boot/overlays/*.dts ; do
			filebase=${file##*/}
			filebase=${filebase%.*}
			dtc -I dts -O dtb -o "/boot/firmware/overlays/$filebase.dtbo" "$file"
		done
	fi
	if [ -d "config" ]; then
		for file in config/* ; do
			cp -a "$file" $ZYNTHIAN_CONFIG_DIR
		done
	fi
	if [ -d "firmware" ]; then
		for file in firmware/* ; do
			cp -a "$file" /lib/firmware
		done
	fi
}


function display_custom_config {
	custom_config "$1"

	calibration_fpath="$ZYNTHIAN_CONFIG_DIR/touchscreen/$DISPLAY_NAME"

	if [ ! -d $ZYNTHIAN_CONFIG_DIR/touchscreen ]; then
		mkdir $ZYNTHIAN_CONFIG_DIR/touchscreen
	fi

	if [ -f "calibration.conf" ]; then
		if [ ! -f "$calibration_fpath" ]; then
			cp -a calibration.conf "$calibration_fpath"
		fi
	fi

	if [ -f "$calibration_fpath" ]; then
		cp -a "$calibration_fpath" /etc/X11/xorg.conf.d/99-calibration.conf
	fi
}


#------------------------------------------------------------------------------
# Default Values for some Config Variables
#------------------------------------------------------------------------------

if [ -z "$FRAMEBUFFER" ]; then
	export FRAMEBUFFER="/dev/fb1"
fi

if [ -f "/usr/local/bin/jackd" ]; then
	export JACKD_BIN_PATH="/usr/local/bin"
else
	export JACKD_BIN_PATH="/usr/bin"
fi

if [ -z "$JACKD_OPTIONS" ]; then
	export JACKD_OPTIONS="-P 70 -t 2000 -s -d alsa -d hw:0 -r 44100 -p 256 -n 2 -X raw"
fi

if [ -z "$ZYNTHIAN_AUBIONOTES_OPTIONS" ]; then
	export ZYNTHIAN_AUBIONOTES_OPTIONS="-O complex -t 0.5 -s -88  -p yinfft -l 0.5"
fi

if [ -z "$ZYNTHIAN_HOSTSPOT_NAME" ]; then
	export ZYNTHIAN_HOSTSPOT_NAME="zynthian"
fi
if [ -z "$ZYNTHIAN_HOSTSPOT_PASSWORD" ]; then
	export ZYNTHIAN_HOSTSPOT_PASSWORD="raspberry"
fi
if [ -z "$ZYNTHIAN_HOSTSPOT_CHANNEL" ]; then
	export ZYNTHIAN_HOSTSPOT_CHANNEL="0"
fi

if [ -z "$BROWSEPY_ROOT" ]; then
	export BROWSEPY_ROOT="$ZYNTHIAN_MY_DATA_DIR/files/mod-ui"
fi

#------------------------------------------------------------------------------
# Escape Config Variables to replace
#------------------------------------------------------------------------------

FRAMEBUFFER_ESC=${FRAMEBUFFER//\//\\\/}
LV2_PATH_ESC=${LV2_PATH//\//\\\/}
ZYNTHIAN_DIR_ESC=${ZYNTHIAN_DIR//\//\\\/}
ZYNTHIAN_CONFIG_DIR_ESC=${ZYNTHIAN_CONFIG_DIR//\//\\\/}
ZYNTHIAN_SYS_DIR_ESC=${ZYNTHIAN_SYS_DIR//\//\\\/}
ZYNTHIAN_UI_DIR_ESC=${ZYNTHIAN_UI_DIR//\//\\\/}
ZYNTHIAN_SW_DIR_ESC=${ZYNTHIAN_SW_DIR//\//\\\/}
BROWSEPY_ROOT_ESC=${BROWSEPY_ROOT//\//\\\/}

JACKD_BIN_PATH_ESC=${JACKD_BIN_PATH//\//\\\/}
JACKD_OPTIONS_ESC=${JACKD_OPTIONS//\//\\\/}
ZYNTHIAN_AUBIONOTES_OPTIONS_ESC=${ZYNTHIAN_AUBIONOTES_OPTIONS//\//\\\/}
ZYNTHIAN_CUSTOM_BOOT_CMDLINE=${ZYNTHIAN_CUSTOM_BOOT_CMDLINE//\n//}

if [ -f "/proc/stat" ]; then
	RBPI_AUDIO_DEVICE=`$ZYNTHIAN_SYS_DIR/sbin/get_rbpi_audio_device.sh`
else
	RBPI_AUDIO_DEVICE="Headphones"
fi

#------------------------------------------------------------------------------
# Boot Config 
#------------------------------------------------------------------------------
BOOT_CONFIG_FPATH="/boot/firmware/config.txt"
CMDLINE_CONFIG_FPATH="/boot/firmware/cmdline.txt"

# Detect NO_ZYNTHIAN_UPDATE flag in the config.txt
if [ -f "$BOOT_CONFIG_FPATH" ] && [ -z "$NO_ZYNTHIAN_UPDATE" ]; then
	NO_ZYNTHIAN_UPDATE=`grep -e ^#NO_ZYNTHIAN_UPDATE $BOOT_CONFIG_FPATH`
fi

if [ -z "$NO_ZYNTHIAN_UPDATE" ]; then
	# Generate cmdline.txt
	cmdline="rootfstype=ext4 fsck.repair=yes rootwait"

	if [ "$ZYNTHIAN_LIMIT_USB_SPEED" == "1" ]; then
		echo "USB SPEED LIMIT ENABLED"
		cmdline="$cmdline dwc_otg.speed=1"
	fi

	if [[ "$DISPLAY_KERNEL_OPTIONS" != "" ]]; then
		cmdline="$cmdline $DISPLAY_KERNEL_OPTIONS"
	fi

	if [[ "$ZYNTHIAN_CUSTOM_BOOT_CMDLINE" != "" ]]; then
		echo "CUSTOM BOOT CMDLINE => $ZYNTHIAN_CUSTOM_BOOT_CMDLINE"
		cmdline="$cmdline $ZYNTHIAN_CUSTOM_BOOT_CMDLINE"
	fi

	if [[ "$FRAMEBUFFER" == "/dev/fb0" ]]; then
		echo "BOOT LOG DISABLED"
		cmdline="$cmdline console=serial0 consoleblank=0 loglevel=2 logo.nologo quiet splash vt.global_cursor_default=0"
	else
		cmdline="$cmdline console=tty1 logo.nologo"
	fi

	# Find rootfs by PARTUUID instead of block device
	# This will allow booting zynthian from USB
	#Find partition id of rootfs ending with -02
	PARTID=$(cat /etc/fstab | grep -Eo "PARTUUID=\S*-02")
	# Replace existing `root=` parameter with PARTUUID
	cmdline="root=$PARTID $cmdline"

	# Customize config.txt
	cp -a $ZYNTHIAN_SYS_DIR/boot/config.txt "$BOOT_CONFIG_FPATH"

	echo "OVERCLOCKING => $ZYNTHIAN_OVERCLOCKING"
	if [[ "$ZYNTHIAN_OVERCLOCKING" == "Maximum" ]]; then
		sed -i -e "s/#OVERCLOCKING_RBPI4#/over_voltage=6\narm_freq=2000/g" "$BOOT_CONFIG_FPATH"
	elif [[ "$ZYNTHIAN_OVERCLOCKING" == "Medium" ]]; then
		sed -i -e "s/#OVERCLOCKING_RBPI4#/over_voltage=2\narm_freq=1750/g" "$BOOT_CONFIG_FPATH"
	else
		sed -i -e "s/#OVERCLOCKING_RBPI4#//g" "$BOOT_CONFIG_FPATH"
	fi

	if [[ "$ZYNTHIAN_DISABLE_RBPI_AUDIO" != "1" ]]; then
		echo "RBPI AUDIO ENABLED"
		sed -i -e "s/#RBPI_AUDIO_CONFIG#/dtparam=audio=on\naudio_pwm_mode=2/g" "$BOOT_CONFIG_FPATH"
	fi

	if [[ "$ZYNTHIAN_DISABLE_OTG" != "1" ]]; then
		echo "OTG ENABLED"
		cmdline="$cmdline modules-load=dwc2,libcomposite"
		sed -i -e "s/#OTG_CONFIG#/dtoverlay=dwc2/g" "$BOOT_CONFIG_FPATH"
	fi

	echo "SOUNDCARD CONFIG => $SOUNDCARD_CONFIG"
	sed -i -e "s/#SOUNDCARD_CONFIG#/$SOUNDCARD_CONFIG/g" "$BOOT_CONFIG_FPATH"

	# Patch piscreen config
	if [[ ( $DISPLAY_CONFIG == *"piscreen2r-notouch"* ) && ( $DISPLAY_CONFIG != *"piscreen2r-backlight"* ) ]]; then
		DISPLAY_CONFIG=$DISPLAY_CONFIG"\ndtoverlay=piscreen2r-backlight"
	fi

	echo "DISPLAY CONFIG => $DISPLAY_CONFIG"
	sed -i -e "s/#DISPLAY_CONFIG#/$DISPLAY_CONFIG/g" "$BOOT_CONFIG_FPATH"

	# Configure RTC for Z1 main boards
	# TODO => see /zynthian-sys/sbin/configure_rtc.sh!!!
	if [[ ( $ZYNTHIAN_KIT_VERSION == "Z1"* ) ]]; then
		export ZYNTHIAN_CUSTOM_CONFIG="dtoverlay=i2c-rtc,rv3028\n"$ZYNTHIAN_CUSTOM_CONFIG
	fi

	echo "CUSTOM CONFIG => $ZYNTHIAN_CUSTOM_CONFIG"
	sed -i -e "s/#CUSTOM_CONFIG#/$ZYNTHIAN_CUSTOM_CONFIG/g" "$BOOT_CONFIG_FPATH"

	# Generate cmdline.txt
	echo "$cmdline" > "$CMDLINE_CONFIG_FPATH"
fi

# Copy extra overlays
if [ -d "$ZYNTHIAN_SYS_DIR/boot/overlays" ]; then
	cp -a $ZYNTHIAN_SYS_DIR/boot/overlays/* /boot/firmware/overlays
fi

#------------------------------------------------------------------------------
# Zynthian Config 
#------------------------------------------------------------------------------
if [ ! -d "$ZYNTHIAN_CONFIG_DIR" ]; then
	mkdir -p "$ZYNTHIAN_CONFIG_DIR"
fi
cd $ZYNTHIAN_CONFIG_DIR

# Install zynthian repository public key
if [ ! -f "/etc/apt/sources.list.d/zynthian.list" ]; then
	apt-key add $ZYNTHIAN_SYS_DIR/etc/apt/pubkeys/zynthian.pub
fi

if [ ! -d "midi-profiles" ]; then
	mkdir "midi-profiles"
	cp "$ZYNTHIAN_SYS_DIR/config/default_midi_profile.sh" "midi-profiles/default.sh"
fi

# Fix/Setup Default Jalv LV2-plugin list
if [ ! -d "jalv" ]; then
	mkdir "jalv"
fi
if [ ! -d "jucy" ]; then
	mkdir "jucy"
fi
if [ -f "jalv_plugins.json" ]; then
	mv "jalv_plugins.json" "jalv/plugins.json"
	mv "all_jalv_plugins.json" "jalv/all_plugins.json"
fi
if [ ! -f "jalv/plugins.json" ]; then
	cp "$ZYNTHIAN_SYS_DIR/config/default_jalv_plugins.json" "jalv/plugins.json"
fi
if [ ! -f "jucy/plugins.json" ]; then
	cp "$ZYNTHIAN_SYS_DIR/config/default_jucy_plugins.json" "jucy/plugins.json"
fi

export ZYNTHIAN_PIANOTEQ_DIR="$ZYNTHIAN_SW_DIR/pianoteq6"
# Setup Pianoteq binary
if [ ! -L "$ZYNTHIAN_PIANOTEQ_DIR/pianoteq" ]; then
	ln -s "$ZYNTHIAN_PIANOTEQ_DIR/Pianoteq 6 STAGE" "$ZYNTHIAN_PIANOTEQ_DIR/pianoteq"
fi
# Generate LV2 presets
ptq_version=$($ZYNTHIAN_PIANOTEQ_DIR/pianoteq --version | cut -d' ' -f4)
if [[ "$version" > "7.2.0" ]]; then
	n_presets=$(find "$ZYNTHIAN_MY_DATA_DIR/presets/lv2" -name "Pianoteq 7 *-factory-presets*.lv2" -printf '.' | wc -m)
	if [[ "$n_presets" == 0 ]]; then
		$ZYNTHIAN_PIANOTEQ_DIR/pianoteq --export-lv2-presets $ZYNTHIAN_MY_DATA_DIR/presets/lv2
	fi
fi
# Setup Pianoteq User Presets Directory
if [ ! -d "/root/.local/share/Modartt/Pianoteq/Presets/My Presets" ]; then
	mkdir -p "/root/.local/share/Modartt/Pianoteq/Presets/My Presets"
fi
if [ ! -L "$ZYNTHIAN_MY_DATA_DIR/presets/pianoteq" ]; then
	ln -s "/root/.local/share/Modartt/Pianoteq/Presets/My Presets" "$ZYNTHIAN_MY_DATA_DIR/presets/pianoteq"
fi
# Setup Pianoteq Config files
if [ ! -d "/root/.config/Modartt" ]; then
	mkdir -p "/root/.config/Modartt"
	cp $ZYNTHIAN_DATA_DIR/pianoteq6/*.prefs /root/.config/Modartt
fi
# Setup Pianoteq MidiMappings
if [ ! -d "/root/.config/Modartt/Pianoteq/MidiMappings" ]; then
	mkdir -p "/root/.local/share/Modartt/Pianoteq/MidiMappings"
	cp $ZYNTHIAN_DATA_DIR/pianoteq6/Zynthian.ptm /root/.local/share/Modartt/Pianoteq/MidiMappings
fi
# Fix Pianoteq Presets Cache location
if [ -d "$ZYNTHIAN_MY_DATA_DIR/pianoteq6" ]; then
	mv "$ZYNTHIAN_MY_DATA_DIR/pianoteq6" $ZYNTHIAN_CONFIG_DIR
fi
# Setup browsepy directories
if [ ! -d "$BROWSEPY_ROOT" ]; then
     mkdir -p $BROWSEPY_ROOT
fi
# TODO create other directories and symlinks to existing file types in $ZYNTHIAN_MY_DATA_DIR
if [ ! -d "$BROWSEPY_ROOT/Speaker Cabinets IRs" ]; then
     mkdir -p "$BROWSEPY_ROOT/Speaker Cabinets IRs"
fi

# Setup Aeolus Config
if [ -d "/usr/share/aeolus" ]; then
	# => Delete specific Aeolus config for replacing with the newer one
	cd $ZYNTHIAN_DATA_DIR
	res=`git rev-parse HEAD`
	if [ "$res" == "ba07bbc8c10cd582c1eea54d40f153fc0ad03dda" ]; then
		rm -f /root/.aeolus-presets
		echo "Deleting incompatible Aeolus presets file..."
	fi
	# => Copy presets file if it doesn't exist
	if [ ! -f "/root/.aeolus-presets" ]; then
		cp -a $ZYNTHIAN_DATA_DIR/aeolus/aeolus-presets /root/.aeolus-presets
	fi
	# => Copy default Waves files if needed
	if [ -n "$(ls -A /usr/share/aeolus/stops/waves 2>/dev/null)" ]; then
		echo "Aeolus Waves already exist!"
	else
		echo "Copying default Aeolus Waves ..."
		cd /usr/share/aeolus/stops
		tar xfz $ZYNTHIAN_DATA_DIR/aeolus/waves.tgz
	fi
fi

#--------------------------------------
# Bootsplash Config
#--------------------------------------
if [[ $ZYNTHIAN_KIT_VERSION == "Z1_V1" ]]; then
	# If device is Z1_V1, change extro video to miko
	sed -i "s/extroVideo=.*/extroVideo=\/usr\/share\/zynthbox-bootsplash\/miko-extro.mp4/" /root/.config/zynthbox/zynthbox-qml.conf
fi

#--------------------------------------
# System Config
#--------------------------------------

if [ -z "$NO_ZYNTHIAN_UPDATE" ]; then
	# Copy "etc" config files
	cp -a $ZYNTHIAN_SYS_DIR/etc/apt/sources.list.d/* /etc/apt/sources.list.d
	cp -a $ZYNTHIAN_SYS_DIR/etc/apt/preferences.d/* /etc/apt/preferences.d
	cp -a $ZYNTHIAN_SYS_DIR/etc/modules /etc
	cp -a $ZYNTHIAN_SYS_DIR/etc/inittab /etc
	cp -a $ZYNTHIAN_SYS_DIR/etc/network/* /etc/network
	cp -an $ZYNTHIAN_SYS_DIR/etc/dbus-1/* /etc/dbus-1
	cp -an $ZYNTHIAN_SYS_DIR/etc/security/* /etc/security
	cp -a $ZYNTHIAN_SYS_DIR/etc/systemd/* /etc/systemd/system
	cp -a $ZYNTHIAN_SYS_DIR/etc/system.conf /etc/systemd/
	cp -a $ZYNTHIAN_SYS_DIR/etc/system.conf.d /etc/systemd/system.conf.d
	cp -a $ZYNTHIAN_SYS_DIR/etc/sysctl.d/* /etc/sysctl.d
	cp -a $ZYNTHIAN_SYS_DIR/etc/udev/rules.d/* /etc/udev/rules.d 2>/dev/null
	cp -a $ZYNTHIAN_SYS_DIR/etc/avahi/* /etc/avahi
	cp -a $ZYNTHIAN_SYS_DIR/etc/default/* /etc/default
	cp -a $ZYNTHIAN_SYS_DIR/etc/ld.so.conf.d/* /etc/ld.so.conf.d
	cp -a $ZYNTHIAN_SYS_DIR/etc/modprobe.d/* /etc/modprobe.d
	cp -an $ZYNTHIAN_SYS_DIR/etc/vim/* /etc/vim
	cp -a $ZYNTHIAN_SYS_DIR/etc/update-motd.d/* /etc/update-motd.d
	# WIFI Hotspot
	cp -an $ZYNTHIAN_SYS_DIR/etc/hostapd/* /etc/hostapd
	cp -a $ZYNTHIAN_SYS_DIR/etc/dnsmasq.conf /etc
	# WIFI Network
	#rm -f /etc/wpa_supplicant/wpa_supplicant.conf
	cp -an $ZYNTHIAN_SYS_DIR/etc/wpa_supplicant/wpa_supplicant.conf $ZYNTHIAN_CONFIG_DIR
fi


# Display zynthian info on ssh login
#sed -i -e "s/PrintMotd no/PrintMotd yes/g" /etc/ssh/sshd_config

# Fix usbmount
if [ "$ZYNTHIAN_OS_CODEBASE" == "stretch" ]; then
	if [ -f "/lib/systemd/system/systemd-udevd.service" ]; then
		sed -i -e "s/MountFlags\=slave/MountFlags\=shared/g" /lib/systemd/system/systemd-udevd.service
	fi
elif [ "$ZYNTHIAN_OS_CODEBASE" == "buster" ]; then
	if [ -f "/lib/systemd/system/systemd-udevd.service" ]; then
		sed -i -e "s/PrivateMounts\=yes/PrivateMounts\=no/g" /lib/systemd/system/systemd-udevd.service
	fi
fi

# X11 Display config
if [ ! -d "/etc/X11/xorg.conf.d" ]; then
	mkdir /etc/X11/xorg.conf.d
fi
# cp -a $ZYNTHIAN_SYS_DIR/etc/X11/xorg.conf.d/99-fbdev.conf /etc/X11/xorg.conf.d
# sed -i -e "s/#FRAMEBUFFER#/$FRAMEBUFFER_ESC/g" /etc/X11/xorg.conf.d/99-fbdev.conf

# Copy fonts to system directory
rsync -r --del $ZYNTHIAN_UI_DIR/fonts/* /usr/share/fonts/truetype

# Fix problem with WLAN interfaces numbering
if [ -f "/etc/udev/rules.d/70-persistent-net.rules" ]; then
	mv /etc/udev/rules.d/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.rules.inactive
	mv /lib/udev/rules.d/75-persistent-net-generator.rules /lib/udev/rules.d/75-persistent-net-generator.rules.inactive
fi
#if [ -f "/etc/udev/rules.d/70-persistent-net.rules.inactive" ]; then
#	rm -f /etc/udev/rules.d/70-persistent-net.rules.inactive
#fi
#Fix timeout in network initialization
if [ ! -d "/etc/systemd/system/networking.service.d/reduce-timeout.conf" ]; then
	mkdir -p "/etc/systemd/system/networking.service.d"
	echo -e "[Service]\nTimeoutStartSec=1\n" > "/etc/systemd/system/networking.service.d/reduce-timeout.conf"
fi

# WIFI Hotspot extra config
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
echo "" > /etc/network/interfaces

# User Config (root)
# => ZynAddSubFX Config
if [ -f $ZYNTHIAN_SYS_DIR/etc/zynaddsubfxXML.cfg ]; then
	cp -a $ZYNTHIAN_SYS_DIR/etc/zynaddsubfxXML.cfg /root/.zynaddsubfxXML.cfg
fi
# => vim config
if [ -f /etc/vim/vimrc.local ]; then
	cp -a /etc/vim/vimrc.local /root/.vimrc
fi

# => vncserver password
if [ ! -d "/root/.vnc" ]; then
	mkdir "/root/.vnc"
fi
if [ ! -f "/root/.vnc/passwd" ]; then
	echo "raspberry" | vncpasswd -f > /root/.vnc/passwd
	chmod go-r /root/.vnc/passwd
fi
# => novnc launcher
if [ ! -f "$ZYNTHIAN_SW_DIR/noVNC/utils/novnc_proxy" ]; then
	ln -s "$ZYNTHIAN_SW_DIR/noVNC/utils/launch.sh" "$ZYNTHIAN_SW_DIR/noVNC/utils/novnc_proxy"
fi

# Device Custom files
display_config_custom_dir="$ZYNTHIAN_SYS_DIR/custom/display/$DISPLAY_NAME"
if [ -d "$display_config_custom_dir" ]; then
	display_custom_config "$display_config_custom_dir"
fi

soundcard_config_custom_dir="$ZYNTHIAN_SYS_DIR/custom/soundcard/$SOUNDCARD_NAME"
if [ -d "$soundcard_config_custom_dir" ]; then
	custom_config "$soundcard_config_custom_dir"
fi

# AudioInjector Alsa Mixer Customization
if [ "$SOUNDCARD_NAME" == "AudioInjector" ]; then
	echo "Configuring Alsa Mixer for AudioInjector ..."
	amixer -c audioinjectorpi sset 'Output Mixer HiFi' unmute
	amixer -c audioinjectorpi cset numid=10,iface=MIXER,name='Line Capture Switch' 1
fi
 
if [ "$SOUNDCARD_NAME" == "AudioInjector Ultra" ]; then
	echo "Configuring Alsa Mixer for AudioInjector Ultra ..."
	amixer -c audioinjectorul cset name='DAC Switch' 0
	amixer -c audioinjectorul cset name='DAC Volume' 240
	amixer -c audioinjectorul cset name='DAC INV Switch' 0
	amixer -c audioinjectorul cset name='DAC Soft Ramp Switch' 0
	amixer -c audioinjectorul cset name='DAC Zero Cross Switch' 0
	amixer -c audioinjectorul cset name='De-emp 44.1kHz Switch' 0
	amixer -c audioinjectorul cset name='E to F Buffer Disable Switch' 0
	amixer -c audioinjectorul cset name='DAC Switch' 1
fi

# Add extra modules
if [[ $RBPI_VERSION == "Raspberry Pi 4"* ]]; then
	echo -e "dwc2\\ng_midi\\n" >> /etc/modules
fi

# Replace config vars in hostapd.conf
sed -i -e "s/#ZYNTHIAN_HOTSPOT_NAME#/$ZYNTHIAN_HOSTSPOT_NAME/g" /etc/hostapd/hostapd.conf
sed -i -e "s/#ZYNTHIAN_HOTSPOT_PASSWORD#/$ZYNTHIAN_HOSTSPOT_PASSWORD/g" /etc/hostapd/hostapd.conf
sed -i -e "s/#ZYNTHIAN_HOTSPOT_CHANNEL#/$ZYNTHIAN_HOSTSPOT_CHANNEL/g" /etc/hostapd/hostapd.conf

# Replace config vars in Systemd service files
# First Boot service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/first_boot.service
# Cpu-performance service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/cpu-performance.service
# Wifi-Setup service
sed -i -e "s/#ZYNTHIAN_CONFIG_DIR#/$ZYNTHIAN_CONFIG_DIR_ESC/g" /etc/systemd/system/wifi-setup.service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/wifi-setup.service
# Splash-Screen Service
sed -i -e "s/#FRAMEBUFFER#/$FRAMEBUFFER_ESC/g" /etc/systemd/system/splash-screen.service
sed -i -e "s/#ZYNTHIAN_DIR#/$ZYNTHIAN_DIR_ESC/g" /etc/systemd/system/splash-screen.service
sed -i -e "s/#ZYNTHIAN_UI_DIR#/$ZYNTHIAN_UI_DIR_ESC/g" /etc/systemd/system/splash-screen.service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/splash-screen.service
sed -i -e "s/#ZYNTHIAN_CONFIG_DIR#/$ZYNTHIAN_CONFIG_DIR_ESC/g" /etc/systemd/system/splash-screen.service
# Jackd service
sed -i -e "s/#JACKD_OPTIONS#/$JACKD_OPTIONS_ESC/g" /etc/systemd/system/jack2.service
sed -i -e "s/#LV2_PATH#/$LV2_PATH_ESC/g" /etc/systemd/system/jack2.service
# a2jmidid service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/a2jmidid.service
# mod-ttymidi service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/mod-ttymidi.service
# Aubionotes service
sed -i -e "s/#ZYNTHIAN_AUBIONOTES_OPTIONS#/$ZYNTHIAN_AUBIONOTES_OPTIONS_ESC/g" /etc/systemd/system/aubionotes.service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/aubionotes.service
# jackrtpmidid service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/jackrtpmidid.service
# qmidinet service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/qmidinet.service
# touchosc2midi service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/touchosc2midi.service
# jack-midi-clock service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/jack-midi-clock.service
# headphones service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/headphones.service
sed -i -e "s/#RBPI_AUDIO_DEVICE#/$RBPI_AUDIO_DEVICE/g" /etc/systemd/system/headphones.service
# MOD-HOST service
sed -i -e "s/#LV2_PATH#/$LV2_PATH_ESC/g" /etc/systemd/system/mod-host.service
sed -i -e "s/#JACKD_BIN_PATH#/$JACKD_BIN_PATH_ESC/g" /etc/systemd/system/mod-host.service
# MOD-SDK service
sed -i -e "s/#LV2_PATH#/$LV2_PATH_ESC/g" /etc/systemd/system/mod-sdk.service
sed -i -e "s/#ZYNTHIAN_SW_DIR#/$ZYNTHIAN_SW_DIR_ESC/g" /etc/systemd/system/mod-sdk.service
# MOD-UI service
sed -i -e "s/#LV2_PATH#/$LV2_PATH_ESC/g" /etc/systemd/system/mod-ui.service
sed -i -e "s/#ZYNTHIAN_SW_DIR#/$ZYNTHIAN_SW_DIR_ESC/g" /etc/systemd/system/mod-ui.service
sed -i -e "s/#BROWSEPY_ROOT#/$BROWSEPY_ROOT_ESC/g" /etc/systemd/system/mod-ui.service
# browsepy service
sed -i -e "s/#BROWSEPY_ROOT#/$BROWSEPY_ROOT_ESC/g" /etc/systemd/system/browsepy.service
# VNCServcer service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" "/etc/systemd/system/vncserver0.service"
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" "/etc/systemd/system/vncserver1.service"
# noVNC service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/novnc0.service
sed -i -e "s/#ZYNTHIAN_SW_DIR#/$ZYNTHIAN_SW_DIR_ESC/g" /etc/systemd/system/novnc0.service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/novnc1.service
sed -i -e "s/#ZYNTHIAN_SW_DIR#/$ZYNTHIAN_SW_DIR_ESC/g" /etc/systemd/system/novnc1.service
# Zynthbox QML Service
sed -i -e "s/#FRAMEBUFFER#/$FRAMEBUFFER_ESC/g" /etc/systemd/system/zynthbox-qml.service
sed -i -e "s/#ZYNTHIAN_DIR#/$ZYNTHIAN_DIR_ESC/g" /etc/systemd/system/zynthbox-qml.service
sed -i -e "s/#ZYNTHIAN_UI_DIR#/$ZYNTHIAN_UI_DIR_ESC/g" /etc/systemd/system/zynthbox-qml.service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/zynthbox-qml.service
sed -i -e "s/#ZYNTHIAN_CONFIG_DIR#/$ZYNTHIAN_CONFIG_DIR_ESC/g" /etc/systemd/system/zynthbox-qml.service
# Zynthian Webconf Service
sed -i -e "s/#ZYNTHIAN_DIR#/$ZYNTHIAN_DIR_ESC/g" /etc/systemd/system/zynthian-webconf.service
sed -i -e "s/#ZYNTHIAN_CONFIG_DIR#/$ZYNTHIAN_CONFIG_DIR_ESC/g" /etc/systemd/system/zynthian-webconf.service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/zynthian-webconf.service
# Check Kit Version service
sed -i -e "s/#ZYNTHIAN_SYS_DIR#/$ZYNTHIAN_SYS_DIR_ESC/g" /etc/systemd/system/check_kit_version.service

# Start custom systemd services
systemctl enable check_kit_version

#--------------------------------------------------------------------------------
# Write the kit version in /zynthian/config/.kit_version to detect changes in kit
#--------------------------------------------------------------------------------
# Store the detected kit version
KIT_VERSION_FILE="$ZYNTHIAN_CONFIG_DIR/.kit_version"
DETECTED_KIT=$(python3 /zynthian/zynthian-sys/sbin/zynthian_autoconfig.py)
echo "$DETECTED_KIT" > "$KIT_VERSION_FILE"
echo "Stored kit version $DETECTED_KIT to $KIT_VERSION_FILE" | systemd-cat -t check_kit_version -p info

# Zynthian apt repository
if [ "$ZYNTHIAN_SYS_BRANCH" != "stable" ]; then
	sed -i -e "s/zynthian-stable/zynthian-testing/g" /etc/apt/sources.list.d/zynthian.list
fi

# Create /boot/firmware/ssh file to enable ssh service on boot
touch /boot/firmware/ssh

# Reload Systemd scripts
systemctl daemon-reload

if [ -f "$ZYNTHIAN_MY_DATA_DIR/scripts/update_zynthian_sys.sh" ]; then
	bash "$ZYNTHIAN_MY_DATA_DIR/scripts/update_zynthian_sys.sh"
fi

#------------------------------------------------------------------------------
