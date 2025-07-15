#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Environment Vars
# 
# Setup Zynthian Environment Variables
# 
# Copyright (C) 2015-2016 Fernando Moyano <jofemodo@zynthian.org>
# Copyright (C) 2024 Anupam Basak <anupam.basak27@gmail.com>
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

export ZYNTHIAN_KIT_VERSION="Custom"

# System Config
export ZYNTHIAN_CUSTOM_BOOT_CMDLINE=""
export ZYNTHIAN_CUSTOM_CONFIG=""
export ZYNTHIAN_OVERCLOCKING="None"
export ZYNTHIAN_LIMIT_USB_SPEED="0"
export ZYNTHIAN_DISABLE_OTG="0"
export ZYNTHIAN_WIFI_MODE="off"

#Audio Config
export SOUNDCARD_NAME="RBPi Headphones"
export SOUNDCARD_CONFIG="dtparam=audio=on\naudio_pwm_mode=2"
export SOUNDCARD_MIXER="Headphone Left,Headphone Right"
export JACKD_OPTIONS="-P 70 -s -d alsa -C plughw:Dummy -P plughw:Headphones -r 44100 -p 1024 -n 3 -X raw"
export ZYNTHIAN_DISABLE_RBPI_AUDIO="0"
export ZYNTHIAN_RBPI_HEADPHONES="1"

#Display Config
export DISPLAY_NAME="Generic HDMI Display"
export DISPLAY_CONFIG="disable_overscan=1\ndtoverlay=vc4-kms-v3d\n"
export DISPLAY_WIDTH=""
export DISPLAY_HEIGHT=""
export FRAMEBUFFER="/dev/fb0"
export DISPLAY_KERNEL_OPTIONS=""

# Zynthian Wiring Config
export ZYNTHIAN_WIRING_LAYOUT="DUMMIES"
export ZYNTHIAN_WIRING_ENCODER_A="0,0,0,0"
export ZYNTHIAN_WIRING_ENCODER_B="0,0,0,0"
export ZYNTHIAN_WIRING_SWITCHES="0,0,0,0"
export ZYNTHIAN_WIRING_MCP23017_I2C_ADDRESS=""
export ZYNTHIAN_WIRING_MCP23017_INTA_PIN=""
export ZYNTHIAN_WIRING_MCP23017_INTB_PIN=""

# Zynthian UI Config
export ZYNTHIAN_UI_COLOR_BG="#000000"
export ZYNTHIAN_UI_COLOR_TX="#ffffff"
export ZYNTHIAN_UI_COLOR_ON="#ff0000"
export ZYNTHIAN_UI_COLOR_PANEL_BG="#3a424d"
export ZYNTHIAN_UI_FONT_FAMILY="Audiowide"
export ZYNTHIAN_UI_FONT_SIZE="16"
export ZYNTHIAN_UI_ENABLE_CURSOR="1"
export ZYNTHIAN_UI_TOUCH_WIDGETS="1"
export ZYNTHIAN_UI_RESTORE_LAST_STATE="1"
export ZYNTHIAN_UI_SNAPSHOT_MIXER_SETTINGS="1"
export ZYNTHIAN_UI_SWITCH_BOLD_MS="300"
export ZYNTHIAN_UI_SWITCH_LONG_MS="2000"
export ZYNTHIAN_UI_SHOW_CPU_STATUS="0"
export ZYNTHIAN_UI_ONSCREEN_BUTTONS="1"
export ZYNTHIAN_UI_VISIBLE_MIXER_STRIPS="0"
export ZYNTHIAN_UI_MULTICHANNEL_RECORDER="1"
export ZYNTHIAN_VNCSERVER_ENABLED="0"
export ZYNTHIAN_MIDI_PLAY_LOOP="0"

# MIDI system configuration
export ZYNTHIAN_SCRIPT_MIDI_PROFILE="/zynthian/config/midi-profiles/default.sh"

# Extra features
export ZYNTHIAN_AUBIONOTES_OPTIONS="-O complex -t 0.5 -s -88  -p yinfft -l 0.5"
#export ZYNTHIAN_AUBIONOTES_OPTIONS="-O hfc -t 0.5 -s -60 -p yinfft -l 0.6"

# Directory Paths
export ZYNTHIAN_DIR="/zynthian"
export ZYNTHIAN_CONFIG_DIR="$ZYNTHIAN_DIR/config"
export ZYNTHIAN_SW_DIR="$ZYNTHIAN_DIR/zynthian-sw"
export ZYNTHIAN_UI_DIR="$ZYNTHIAN_DIR/zynthbox-qml"
export ZYNTHIAN_SYS_DIR="$ZYNTHIAN_DIR/zynthian-sys"
export ZYNTHIAN_DATA_DIR="$ZYNTHIAN_DIR/zynthian-data"
export ZYNTHIAN_MY_DATA_DIR="$ZYNTHIAN_DIR/zynthian-my-data"
export ZYNTHIAN_EX_DATA_DIR="/media/root"
export ZYNTHIAN_SCRIPTS_DIR="$ZYNTHIAN_DIR/zynthian-sys/scripts"
export ZYNTHIAN_RECIPE_DIR="$ZYNTHIAN_SCRIPTS_DIR/recipes"
export ZYNTHIAN_PLUGINS_DIR="$ZYNTHIAN_DIR/zynthian-plugins"
export ZYNTHIAN_PLUGINS_SRC_DIR="$ZYNTHIAN_SW_DIR/plugins"
export LV2_PATH="/usr/lib/lv2:/usr/lib/arm-linux-gnueabihf/lv2:/usr/local/lib/lv2:$ZYNTHIAN_PLUGINS_DIR/lv2:$ZYNTHIAN_DATA_DIR/presets/lv2:$ZYNTHIAN_MY_DATA_DIR/presets/lv2"
export VST3_PATH="/usr/lib/vst3:/usr/local/lib/vst3/"

# Hardware Architecture & Optimization Options
hw_architecture=`uname -m 2>/dev/null`
if [ -e "/sys/firmware/devicetree/base/model" ]; then
	rbpi_version=`tr -d '\0' < /sys/firmware/devicetree/base/model`
else
	rbpi_version=""
fi
export MACHINE_HW_NAME=$hw_architecture
export RBPI_VERSION=$rbpi_version
export CFLAGS_UNSAFE=""
export RASPI=true
#echo "Hardware Architecture: ${hw_architecture}"
#echo "Hardware Model: ${rbpi_version}"

if echo $RBPI_VERSION | grep -q "Raspberry Pi 5" || [ $MACHINE_HW_NAME = "aarch64" ]; then
	export CFLAGS="-march=armv8.2-a+crc+crypto -mtune=cortex-a76 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"
elif echo $RBPI_VERSION | grep -q "Raspberry Pi 4" || [ $MACHINE_HW_NAME = "armhf" ]; then
	export CFLAGS="-mcpu=cortex-a72 -mtune=cortex-a72 -mfloat-abi=hard -mfpu=neon-fp-armv8 -mlittle-endian -munaligned-access -mvectorize-with-neon-quad -ftree-vectorize"
fi

export CXXFLAGS=${CFLAGS}

if echo $RBPI_VERSION | grep -q "Raspberry Pi 5"; then
	export GPIO_CHIP_DEVICE="/dev/gpiochip4"
elif echo $RBPI_VERSION | grep -q "Raspberry Pi 4"; then
	export GPIO_CHIP_DEVICE="/dev/gpiochip0"
fi

# Setup / Build Options
export ZYNTHIAN_SETUP_APT_CLEAN="TRUE" # Set TRUE to clean /var/cache/apt during build, FALSE to leave alone

# Activate Python virtual environment
if [ -f "$ZYNTHIAN_DIR/venv/bin/activate" ]; then
	source "$ZYNTHIAN_DIR/venv/bin/activate"
fi
