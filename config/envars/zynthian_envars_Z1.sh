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

export ZYNTHIAN_KIT_VERSION="Z1_V1"
export GPIO_CHIP_DEVICE="/dev/gpiochip4"

# System Config
export XRANDR_ROTATE="inverted"
export ZYNTHIAN_CUSTOM_BOOT_CMDLINE=""
export ZYNTHIAN_CUSTOM_CONFIG=""
export ZYNTHIAN_OVERCLOCKING="Maximum"
export ZYNTHIAN_LIMIT_USB_SPEED="0"
export ZYNTHIAN_DISABLE_OTG="0"
export ZYNTHIAN_WIFI_MODE="off"

#Audio Config
export SOUNDCARD_NAME="Z1 ADAC"
export SOUNDCARD_CONFIG="dtoverlay=hifiberry-dacplusadcpro\nforce_eeprom_read=0"
export SOUNDCARD_MIXER="PGA_Gain_Left,PGA_Gain_Right,ADC_Left_Input,ADC_Right_Input,Digital_0,Digital_1"
export ZYNTHIAN_DISABLE_RBPI_AUDIO="0"
export ZYNTHIAN_RBPI_HEADPHONES="0"
export JACKD_OPTIONS="--port-max 4096 -P 70 -s -S -d alsa -S -d hw:sndrpihifiberry -r 48000 -p 256 -n 2 -i 2 -o 2 -X raw"

#Display Config
export DISPLAY_NAME="Z1 Display"
export DISPLAY_CONFIG="hdmi_force_hotplug:0=0\nhdmi_force_hotplug:1=1\nhdmi_drive:1=1\nhdmi_group:1=2\nhdmi_mode:1=87\nhdmi_cvt:1 1024 600 60 6 0 0 0\ndtoverlay=vc4-kms-v3d\ndtoverlay=goodix_z1"
export DISPLAY_WIDTH="1024"
export DISPLAY_HEIGHT="600"
export FRAMEBUFFER="/dev/fb0"
# Rotate only framebuffer by 180deg. Display/touch rotation needs to be done with xrandr for pointer to also be rotated along with display and touch
export DISPLAY_KERNEL_OPTIONS="video=HDMI-A-2:1024x600M@60,rotate=0 fbcon=rotate:2"

# Zynthian Wiring Config
export ZYNTHIAN_WIRING_LAYOUT="Z1_V1"

# MIDI system configuration
export ZYNTHIAN_SCRIPT_MIDI_PROFILE="/zynthian/config/midi-profiles/default.sh"

# Extra features
export ZYNTHIAN_AUBIONOTES_OPTIONS="-O complex -t 0.5 -s -88  -p yinfft -l 0.5"
