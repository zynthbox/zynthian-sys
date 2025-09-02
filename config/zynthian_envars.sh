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
DETECTED_KIT=$(python3 /zynthian/zynthian-sys/sbin/zynthian_autoconfig.py)
source "/zynthian/zynthian-sys/config/envars/zynthian_envars_$DETECTED_KIT.sh"
