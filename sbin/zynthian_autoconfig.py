#!/usr/bin/python3
# -*- coding: utf-8 -*-
# ********************************************************************
# ZYNTHIAN PROJECT: Zynthian Hardware Autoconfig
#
# Auto-detect & config some hardware configurations
#
# Copyright (C) 2023 Fernando Moyano <jofemodo@zynthian.org>
# Copyright (C) 2024 Anupam Basak <anupam.basak27@gmail.com>
#
# ********************************************************************
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
#
# ********************************************************************

import os
import sys
import logging
from subprocess import check_output


logging.basicConfig(format='%(levelname)s:%(module)s.%(funcName)s: %(message)s', stream=sys.stdout, level=logging.DEBUG)


# --------------------------------------------------------------------
# Hardware's config for several boards:
# --------------------------------------------------------------------


hardware_config = {
    "Z1_MAIN": ["PCM1863@0x4A", "PCM5242@0x4D", "RV3028@0x52"],
    "Z1_CONTROL": ["MCP23017@0x20", "MCP23017@0x21", "ADS1115@0x48", "ADS1115@0x49"],
}

# --------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------


def get_i2c_chips():
    out = check_output("i2cdetect -y 1", shell=True).decode().split("\n")
    if len(out) > 3:
        res = []
        for i in range(0, 8):
            parts = out[i+1][4:].split(" ")
            for j in range(0, 16):
                try:
                    adr = i * 16 + j
                    #logging.info("Detecting at {:02X} => {}".format(adr, parts[j]))
                    if parts[j] != "--":
                        if 0x20 <= adr <= 0x27:
                            res.append("MCP23017@0x{:02X}".format(adr))
                        elif 0x48 <= adr <= 0x49:
                            res.append("ADS1115@0x{:02X}".format(adr))
                        elif adr == 0x4A:
                            res.append("PCM1863@0x{:02X}".format(adr))
                        elif adr == 0x4D:
                            res.append("PCM5242@0x{:02X}".format(adr))
                        elif adr == 0x52:
                            res.append("RV3028@0x{:02X}".format(adr))
                        #elif adr == 0x60 and parts[j] == "UU":
                        elif adr == 0x60:
                            res.append("TPA6130@0x{:02X}".format(adr))
                        elif 0x61 <= adr <= 0x64:
                            res.append("MCP4728@0x{:02X}".format(adr))
                except:
                    pass
    return res


def check_boards(board_names):
    logging.info("Checking Boards: {}".format(board_names))
    faults = []
    for bname in board_names:
        for chip in hardware_config[bname]:
            if chip not in i2c_chips:
                faults.append(chip)
    if len(faults) > 0:
        logging.info("ERROR: Undetected Hardware {}".format(faults))
        return False
    else:
        logging.info("OK: All hardware has been detected!")
        return True


def autodetect_config():
    if check_boards(["Z1_MAIN", "Z1_CONTROL"]):
        config_name = "Z1"
    else:
        config_name = "Custom"
    return config_name

# --------------------------------------------------------------------

# Get list of i2c chips
i2c_chips = get_i2c_chips()
logging.info("Detected I2C Chips: {}".format(i2c_chips))

# Detect kit version
config_name = autodetect_config()
logging.info("Detected {} kit!".format(config_name))

# Configure Zynthian
if config_name:
    if config_name != os.environ.get('ZYNTHIAN_KIT_VERSION'):
        logging.info("Configuring Zynthian for {} ...".format(config_name))

        zyn_dir = os.environ.get('ZYNTHIAN_DIR', "/zynthian")
        zsys_dir = os.environ.get('ZYNTHIAN_SYS_DIR', "/zynthian/zynthian-sys")
        zconfig_dir = os.environ.get('ZYNTHIAN_CONFIG_DIR', "/zynthian/config")

        check_output("cp -a '{}/config/zynthian_envars_{}.sh' '{}/zynthian_envars.sh'".format(zsys_dir, config_name, zconfig_dir), shell=True)
    else:
        logging.info("Zynthian already configured for {}.".format(config_name))
else:
    logging.info("Autoconfig for this HW is not available.")

# --------------------------------------------------------------------
