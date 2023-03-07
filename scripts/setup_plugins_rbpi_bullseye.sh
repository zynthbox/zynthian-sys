#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Setup Zynthian Plugins from scratch for RBPi
# 
# Install LV2 Plugin Package / Download, build and install LV2 Plugins
# 
# Copyright (C) 2015-2016 Fernando Moyano <jofemodo@zynthian.org>
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
# 
#******************************************************************************

source zynthian_envars.sh

#------------------------------------------------
# Create Plugins Source Code Directory
#------------------------------------------------

mkdir $ZYNTHIAN_PLUGINS_SRC_DIR

#------------------------------------------------
# Install LV2 Plugins from repository
#------------------------------------------------

# TODO review:
# surge => Fails from repo. Install our own binary.
# avw.lv2

apt-get -yy install \
    abgate adlplug amsynth ams-lv2 arctican-plugins-lv2 artyfx avldrums.lv2 \
    bchoppr beatslash-lv2 blop-lv2 bsequencer bshapr bslizr \
    calf-plugins caps-lv2 cv-lfo-blender-lv2 \
    drumkv1-lv2 samplv1-lv2 synthv1-lv2 padthv1-lv2 \
    distrho-plugin-ports-lv2 drmr drowaudio-plugins-lv2 drumgizmo \
    easyssp-lv2 eq10q fabla g2reverb geonkick gxplugins gxvoxtonebender \
    helm hybridreverb2 infamous-plugins invada-studio-plugins-lv2 juced-plugins-lv2 juce-opl-lv2 \
    klangfalter-lv2 lufsmeter-lv2 luftikus-lv2 lv2vocoder \
    mod-cv-plugins mod-distortion mod-pitchshifter mod-utilities moony.lv2 \
    noise-repellent obxd-lv2 oxefmsynth pitcheddelay-lv2 pizmidi-plugins \
    regrader rubberband-lv2 safe-plugins shiro-plugins sorcer \
    temper-lv2 tal-plugins-lv2 tap-lv2 teragonaudio-plugins-lv2 vitalium-lv2 \
    wolf-shaper wolf-spectrum wolpertinger-lv2 \
    x42-plugins zam-plugins zlfo
    # dpf-plugins dragonfly-reverb lsp-plugins
    

#----------------------------------------------------
# Install LV2 Plugins packages built from source code
#----------------------------------------------------

apt-get -yy install \
    zynthbox-plugin-sooperlooper-lv2-plugin \
    zynthbox-plugin-sosynth zynthbox-plugin-guitarix zynthbox-plugin-gxswitchlesswah \
    zynthbox-plugin-gxdenoiser2 zynthbox-plugin-gxdistortionplus zynthbox-plugin-foo-yc20 \
    zynthbox-plugin-raffo zynthbox-plugin-triceratops zynthbox-plugin-swh zynthbox-plugin-mod-tap \
    zynthbox-plugin-mod-mda zynthbox-plugin-dexed-lv2 zynthbox-plugin-string-machine \
    zynthbox-plugin-midi-display zynthbox-plugin-punk-console zynthbox-plugin-remid \
    zynthbox-plugin-miniopl3 zynthbox-plugin-ykchorus zynthbox-plugin-gula \
    zynthbox-plugin-mod-arpeggiator zynthbox-plugin-stereo-mixer zynthbox-plugin-alo \
    zynthbox-plugin-vl1 zynthbox-plugin-qmidiarp zynthbox-plugin-mod-cabsim-ir-loader \
    zynthbox-plugin-bolliedelay zynthbox-plugin-mclk zynthbox-plugin-lv2-plugins-prebuilt
# zynthbox-plugin-fluidsynth zynthbox-plugin-fluidplug 
# zynthbox-plugin-setbfree.sh
# zynthbox-plugin-surge-prebuilt.sh

# Fixup amsynth bank/presets
$ZYNTHIAN_RECIPE_DIR/fixup_amsynth.sh

# Install MOD-UI skins
#$ZYNTHIAN_RECIPE_DIR/postinstall_mod-lv2-data.sh
