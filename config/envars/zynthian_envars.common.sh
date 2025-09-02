#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Common Environment Vars
#
# Copyright (C) 2025 Anupam Basak <anupam.basak27@gmail.com>
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
if echo $RBPI_VERSION | grep -q "Raspberry Pi 5" || [ $MACHINE_HW_NAME = "aarch64" ]; then
	export CFLAGS="-march=armv8.2-a+crc+crypto -mtune=cortex-a76 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"
elif echo $RBPI_VERSION | grep -q "Raspberry Pi 4" || [ $MACHINE_HW_NAME = "armhf" ]; then
	export CFLAGS="-mcpu=cortex-a72 -mtune=cortex-a72 -mfloat-abi=hard -mfpu=neon-fp-armv8 -mlittle-endian -munaligned-access -mvectorize-with-neon-quad -ftree-vectorize"
fi
export CXXFLAGS=${CFLAGS}

# GPIO Configuration
if echo $RBPI_VERSION | grep -q "Raspberry Pi 5"; then
	export GPIO_CHIP_DEVICE="/dev/gpiochip4"
elif echo $RBPI_VERSION | grep -q "Raspberry Pi 4"; then
	export GPIO_CHIP_DEVICE="/dev/gpiochip0"
fi

# Zynthian UI Config
export ZYNTHIAN_UI_COLOR_BG="#000000"
export ZYNTHIAN_UI_COLOR_TX="#ffffff"
export ZYNTHIAN_UI_COLOR_ON="#ff0000"
export ZYNTHIAN_UI_COLOR_PANEL_BG="#3a424d"
export ZYNTHIAN_UI_FONT_FAMILY="Audiowide"
export ZYNTHIAN_UI_FONT_SIZE="18"
export ZYNTHIAN_UI_ENABLE_CURSOR="1"
export ZYNTHIAN_UI_TOUCH_WIDGETS="0"
export ZYNTHIAN_UI_RESTORE_LAST_STATE="1"
export ZYNTHIAN_UI_SNAPSHOT_MIXER_SETTINGS="0"
export ZYNTHIAN_UI_SWITCH_BOLD_MS="300"
export ZYNTHIAN_UI_SWITCH_LONG_MS="2000000"
export ZYNTHIAN_UI_SHOW_CPU_STATUS="0"
export ZYNTHIAN_UI_ONSCREEN_BUTTONS="0"
export ZYNTHIAN_VNCSERVER_ENABLED="0"

# Directory Paths
export ZYNTHIAN_DIR="/zynthian"
export ZYNTHIAN_CONFIG_DIR="$ZYNTHIAN_DIR/config"
export ZYNTHIAN_SW_DIR="$ZYNTHIAN_DIR/zynthian-sw"
export ZYNTHIAN_UI_DIR="$ZYNTHIAN_DIR/zynthbox-qml"
export ZYNTHIAN_SYS_DIR="$ZYNTHIAN_DIR/zynthian-sys"
export ZYNTHIAN_DATA_DIR="$ZYNTHIAN_DIR/zynthian-data"
export ZYNTHIAN_MY_DATA_DIR="$ZYNTHIAN_DIR/zynthian-my-data"
export ZYNTHIAN_EX_DATA_DIR="/media/usb0"
export ZYNTHIAN_RECIPE_DIR="$ZYNTHIAN_SYS_DIR/scripts/recipes"
export ZYNTHIAN_PLUGINS_DIR="$ZYNTHIAN_DIR/zynthian-plugins"
export ZYNTHIAN_PLUGINS_SRC_DIR="$ZYNTHIAN_SW_DIR/plugins"
export LV2_PATH="/usr/lib/lv2:/usr/lib/aarch64-linux-gnu/lv2:/usr/local/lib/lv2:$ZYNTHIAN_PLUGINS_DIR/lv2:$ZYNTHIAN_DATA_DIR/presets/lv2:$ZYNTHIAN_MY_DATA_DIR/presets/lv2"
export VST3_PATH="/usr/lib/vst3:/usr/local/lib/vst3/"

# MIDI system configuration
export ZYNTHIAN_SCRIPT_MIDI_PROFILE="/zynthian/config/midi-profiles/default.sh"

# Activate Python virtual environment
if [ -f "$ZYNTHIAN_DIR/venv/bin/activate" ]; then
	source "$ZYNTHIAN_DIR/venv/bin/activate"
fi
