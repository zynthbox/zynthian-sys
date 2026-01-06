#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Environment Vars
# 
# Setup Zynthian Environment Variables
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

# Source common envars
source "/zynthian/zynthian-sys/config/envars/zynthian_envars.common.sh"

# Detect kit and source respective envars file
DETECTED_KIT=$(python3 /zynthian/zynthian-sys/sbin/detect_zynthbox_kit.py)
ENVARS_FILE="/zynthian/zynthian-sys/config/envars/zynthian_envars_${DETECTED_KIT}.sh"
if [[ -f "$ENVARS_FILE" ]]; then
    source "$ENVARS_FILE"
else
    source "/zynthian/zynthian-sys/config/envars/zynthian_envars_Custom.sh"
fi

# Source user envars if exists
if [ -f "/zynthian/config/zynthian_envars.user.sh" ]; then
    source "/zynthian/config/zynthian_envars.user.sh"
fi

# If FORCED_ZYNTHIAN_WIRING_LAYOUT is set in user envars file, update WIRING LAYOUT to forced value
if [[ -n "$FORCED_ZYNTHIAN_WIRING_LAYOUT" && "$FORCED_ZYNTHIAN_WIRING_LAYOUT" != "AUTO_DETECT" ]]; then
    export ZYNTHIAN_WIRING_LAYOUT="$FORCED_ZYNTHIAN_WIRING_LAYOUT"
fi
