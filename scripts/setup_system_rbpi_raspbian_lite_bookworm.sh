#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Setup Script
# 
# Setup a Zynthian Box in a fresh raspbian-lite "bookworm" image
# 
# Copyright (C) 2015-2019 Fernando Moyano <jofemodo@zynthian.org>
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

export DEBIAN_FRONTEND=noninteractive

#------------------------------------------------
# Set default config
#------------------------------------------------

[ -n "$ZYNTHIAN_INCLUDE_RPI_UPDATE" ] || ZYNTHIAN_INCLUDE_RPI_UPDATE=no
[ -n "$ZYNTHIAN_INCLUDE_PIP" ] || ZYNTHIAN_INCLUDE_PIP=yes
[ -n "$ZYNTHIAN_CHANGE_HOSTNAME" ] || ZYNTHIAN_CHANGE_HOSTNAME=yes

[ -n "$ZYNTHIAN_SYS_REPO" ] || ZYNTHIAN_SYS_REPO="https://github.com/zynthbox/zynthian-sys.git"
[ -n "$ZYNTHIAN_UI_REPO" ] || ZYNTHIAN_UI_REPO="https://github.com/zynthbox/zynthian-qml.git"
[ -n "$ZYNTHIAN_ZYNCODER_REPO" ] || ZYNTHIAN_ZYNCODER_REPO="https://github.com/zynthbox/zyncoder.git"
[ -n "$ZYNTHIAN_WEBCONF_REPO" ] || ZYNTHIAN_WEBCONF_REPO="https://github.com/zynthbox/zynthian-webconf.git"
[ -n "$ZYNTHIAN_DATA_REPO" ] || ZYNTHIAN_DATA_REPO="https://github.com/zynthian/zynthian-data.git"
[ -n "$ZYNTHIAN_SYS_BRANCH" ] || ZYNTHIAN_SYS_BRANCH="main"
[ -n "$ZYNTHIAN_UI_BRANCH" ] || ZYNTHIAN_UI_BRANCH="main"
[ -n "$ZYNTHIAN_ZYNCODER_BRANCH" ] || ZYNTHIAN_ZYNCODER_BRANCH="stable"
[ -n "$ZYNTHIAN_WEBCONF_BRANCH" ] || ZYNTHIAN_WEBCONF_BRANCH="main"
[ -n "$ZYNTHIAN_DATA_BRANCH" ] || ZYNTHIAN_DATA_BRANCH="stable"

#------------------------------------------------
# Update System & Firmware
#------------------------------------------------

# Hold kernel version 
#apt-mark hold raspberrypi-kernel

# Update System
apt-get -y update --allow-releaseinfo-change
apt-get -y dist-upgrade

# Install required dependencies if needed
apt-get -y install apt-utils apt-transport-https rpi-update sudo software-properties-common parted dirmngr rpi-eeprom gpgv ca-certificates
#htpdate

# Adjust System Date/Time
#htpdate -s www.pool.ntp.org wikipedia.org google.com

# Update Firmware
if [ "$ZYNTHIAN_INCLUDE_RPI_UPDATE" == "yes" ]; then
    rpi-update
fi

#------------------------------------------------
# Add Repositories
#------------------------------------------------

# deb-multimedia repo
echo "deb http://www.deb-multimedia.org bookworm main non-free" >> /etc/apt/sources.list
wget https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb
dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
rm -f deb-multimedia-keyring_2016.8.1_all.deb

# KXStudio
wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_10.0.3_all.deb
dpkg -i kxstudio-repos_10.0.3_all.deb
rm -f kxstudio-repos_10.0.3_all.deb

# Zynthian
# wget -O - https://deb.zynthian.org/zynthian-deb.pub | apt-key add -
# echo "deb https://deb.zynthian.org/zynthian-stable buster main" > /etc/apt/sources.list.d/zynthian.list

# Zynthbox
if [ ! -z "$ZYNTHIANOS_ZYNTHBOX_REPO_KEY_URL" -a ! -z "$ZYNTHIANOS_ZYNTHBOX_REPO_SOURCELINE" ]; then
	wget -qO - "$ZYNTHIANOS_ZYNTHBOX_REPO_KEY_URL" | apt-key add -
	echo "$ZYNTHIANOS_ZYNTHBOX_REPO_SOURCELINE" > /etc/apt/sources.list.d/zynthbox.list
fi

apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove

#------------------------------------------------
# Install Required Packages
#------------------------------------------------

# System
apt-get -y remove --purge isc-dhcp-client triggerhappy logrotate dphys-swapfile
SYSTEM_PACKAGES="systemd avahi-daemon dhcpcd-dbus usbutils usbmount exfat-utils \
	xinit xserver-xorg-video-fbdev x11-xserver-utils xinput libgl1-mesa-dri vnc4server \
	xfwm4 xfwm4-themes xfce4-panel xdotool \
	wpasupplicant wireless-tools iw hostapd dnsmasq \
	firmware-brcm80211 firmware-atheros firmware-realtek atmel-firmware firmware-misc-nonfree"

# CLI Tools
CLI_TOOLS_PACKAGES="raspi-config psmisc tree joe nano vim p7zip-full i2c-tools \
	fbi scrot mpg123  mplayer xloadimage imagemagick fbcat abcmidi evtest libts-bin"

PYTHON_PACKAGES="python3 python3-dev cython3 python3-cffi python3-tk python3-dbus python3-mpmath python3-pil python3-pip \
	python3-pil.imagetk python3-setuptools python3-pyqt5 python3-numpy-dev python3-evdev 2to3 python-is-python3"

apt-get -y install $SYSTEM_PACKAGES $CLI_TOOLS_PACKAGES $PYTHON_PACKAGES

#------------------------------------------------
# Development Environment
#------------------------------------------------

#Tools
BUILD_TOOLS_PACKAGES="build-essential git swig subversion pkg-config autoconf automake \
	premake gettext intltool libtool libtool-bin cmake cmake-curses-gui flex bison ngrep \
	qt5-qmake gobjc++ ruby rake xsltproc vorbis-tools zenity"
# AV Libraries => WARNING It should be changed on every new debian version!!
AV_LIBS_PACKAGES="libavformat-dev libavcodec-dev ffmpeg"
# Libraries
LIBS_PACKAGES="libfftw3-dev libmxml-dev zlib1g-dev fluid libfltk1.3-dev \
libfltk1.3-compat-headers libncurses5-dev liblo-dev dssi-dev libjpeg-dev libxpm-dev libcairo2-dev libglu1-mesa-dev \
libasound2-dev dbus-x11 jackd2 libjack-jackd2-dev a2jmidid libffi-dev \
fontconfig-config libfontconfig1-dev libxft-dev libexpat-dev libglib2.0-dev libgettextpo-dev libsqlite3-dev \
libglibmm-2.4-dev libeigen3-dev libsndfile-dev libsamplerate-dev libarmadillo-dev libreadline-dev \
lv2-c++-tools libxi-dev libgtk2.0-dev libgtkmm-2.4-dev liblrdf-dev libboost-system-dev libzita-convolver-dev \
libzita-resampler-dev fonts-roboto libxcursor-dev libxinerama-dev mesa-common-dev libgl1-mesa-dev \
libfreetype6-dev  libswscale-dev  qtbase5-dev qtdeclarative5-dev libcanberra-gtk-module \
libcanberra-gtk3-module libxcb-cursor-dev libgtk-3-dev libxcb-util0-dev libxcb-keysyms1-dev libxcb-xkb-dev \
libxkbcommon-x11-dev libssl-dev libtag1-dev"
EXTRA_PACKAGES="jack-midi-clock midisport-firmware"
WM_PACKAGES="kwin-x11"

apt-get -y --no-install-recommends install $BUILD_TOOLS_PACKAGES $AV_LIBS_PACKAGES $LIBS_PACKAGES $EXTRA_PACKAGES $WM_PACKAGES

PIP3_PACKAGES="tornado==4.1 tornadostreamform websocket-client jsonpickle oyaml psutil pexpect requests mido python-rtmidi psutil"
ZYNTHBOX_PIP3_PACKAGES="soundfile pytaglib pynput rpi_ws281x"
MOD_UI_PIP3_PACKAGES="pyserial==3.0 pystache==0.5.4 aggdraw==1.3.11 pycrypto"

# Allow installing python modules to system repo
rm /usr/lib/python3*/EXTERNALLY-MANAGED

pip3 install $PIP3_PACKAGES $ZYNTHBOX_PIP3_PACKAGES $MOD_UI_PIP3_PACKAGES

ZYNTHBOX_OTHER_DEPENDENCIES="zynaddsubfx fluid-soundfont-gm fluid-soundfont-gs timgm6mb-soundfont \
linuxsampler gigtools  puredata puredata-core puredata-utils python3-yaml pd-lua pd-moonlib \
pd-pdstring pd-markex pd-iemnet pd-plugin pd-ekext pd-import pd-bassemu pd-readanysf pd-pddp \
pd-zexy pd-list-abs pd-flite pd-windowing pd-fftease pd-bsaylor pd-osc pd-sigpack pd-hcs pd-pdogg pd-purepd \
pd-beatpipe pd-freeverb pd-iemlib pd-smlib pd-hid pd-csound pd-earplug pd-wiimote pd-pmpd pd-motex \
pd-arraysize pd-ggee pd-chaos pd-iemmatrix pd-comport pd-libdir pd-vbap pd-cxc pd-lyonpotpourri pd-iemambi \
pd-pdp pd-mjlib pd-cyclone pd-jmmmp pd-3dp pd-boids pd-mapping pd-maxlib \
zynthbox-dependency-mod-host zynthbox-dependency-mod-browsepy zynthbox-dependency-mod-ui sfizz"
# mididings pd-aubio

# Install ZynthboxQML and its dependencies
apt-get -y install zynthbox-meta $ZYNTHBOX_OTHER_DEPENDENCIES

#************************************************
#------------------------------------------------
# Create Zynthian Directory Tree & 
# Install Zynthian Software from repositories
#------------------------------------------------
#************************************************

# Create needed directories
mkdir "$ZYNTHIAN_DIR"
mkdir "$ZYNTHIAN_CONFIG_DIR"
mkdir "$ZYNTHIAN_SW_DIR"

# Zynthian System Scripts and Config files
cd $ZYNTHIAN_DIR
git clone -b "${ZYNTHIAN_SYS_BRANCH}" "${ZYNTHIAN_SYS_REPO}"

# Install WiringPi
# TODO : Package deb
$ZYNTHIAN_RECIPE_DIR/install_wiringpi.sh

# Zynthian Data
cd $ZYNTHIAN_DIR
git clone -b "${ZYNTHIAN_DATA_BRANCH}" "${ZYNTHIAN_DATA_REPO}"

# Create needed directories
#mkdir "$ZYNTHIAN_DATA_DIR/soundfonts"
#mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/sf2"
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/gig"
mkdir "$ZYNTHIAN_MY_DATA_DIR"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/lv2"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/zynaddsubfx"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/zynaddsubfx/XMZ"
#mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/zynaddsubfx/XSZ"
#mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/zynaddsubfx/XLZ"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/mod-ui"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/mod-ui/pedalboards"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/puredata"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/puredata/generative"
mkdir "$ZYNTHIAN_MY_DATA_DIR/presets/puredata/synths"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sf2"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sfz"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/gig"
mkdir "$ZYNTHIAN_MY_DATA_DIR/snapshots"
mkdir "$ZYNTHIAN_MY_DATA_DIR/snapshots/000"
mkdir "$ZYNTHIAN_MY_DATA_DIR/capture"
mkdir "$ZYNTHIAN_MY_DATA_DIR/preset-favorites"
mkdir "$ZYNTHIAN_PLUGINS_DIR"
mkdir -p "$ZYNTHIAN_PLUGINS_DIR/lv2"
# ln -s /usr/lib/lv2 "$ZYNTHIAN_PLUGINS_DIR/lv2"

# Copy default snapshots
cp -a $ZYNTHIAN_SYS_DIR/snapshots/default.zss $ZYNTHIAN_MY_DATA_DIR/snapshots/

#************************************************
#------------------------------------------------
# System Adjustments
#------------------------------------------------
#************************************************

#Change Hostname
if [ "$ZYNTHIAN_CHANGE_HOSTNAME" == "yes" ]; then
    echo "zynthian" > /etc/hostname
    sed -i -e "s/127\.0\.1\.1.*$/127.0.1.1\tzynthian/" /etc/hosts
fi

# Copy default envars
cp -a $ZYNTHIAN_SYS_DIR/scripts/zynthian_envars.sh $ZYNTHIAN_CONFIG_DIR

# Copy default engine edit pages config
cp -a $ZYNTHIAN_SYS_DIR/config/control_page.conf $ZYNTHIAN_CONFIG_DIR

# Run configuration script
$ZYNTHIAN_SYS_DIR/scripts/update_zynthian_data.sh
$ZYNTHIAN_SYS_DIR/scripts/update_zynthian_sys.sh

# Configure Systemd Services
systemctl daemon-reload
systemctl enable dhcpcd
systemctl enable avahi-daemon
systemctl disable raspi-config
systemctl disable cron
systemctl disable rsyslog
systemctl disable ntp
systemctl disable htpdate
systemctl disable wpa_supplicant
systemctl disable hostapd
systemctl disable dnsmasq
systemctl disable unattended-upgrades
systemctl disable apt-daily.timer
systemctl disable getty@tty1.service
systemctl disable splash-screen
systemctl disable userconfig.service
systemctl enable backlight
systemctl enable cpu-performance
# systemctl enable check-ttymidi-usage.service
# systemctl enable check-ttymidi-usage.timer
systemctl enable wifi-setup
systemctl enable jack2
systemctl enable mod-ttymidi
systemctl enable a2jmidid
systemctl enable zynthbox-qml
systemctl enable zynthian-webconf
systemctl enable zynthian-webconf-fmserver
systemctl enable zynthian-config-on-boot

# Setup loading of Zynthian Environment variables ...
echo "source $ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh" >> /root/.bashrc
# => Shell & Login Config
echo "source $ZYNTHIAN_SYS_DIR/etc/profile.zynthian" >> /root/.profile

# On first boot, resize SD partition, regenerate keys, etc.
$ZYNTHIAN_SYS_DIR/scripts/set_first_boot.sh


#************************************************
#------------------------------------------------
# Compile / Install Required Libraries
#------------------------------------------------
#************************************************

# Install zynthbox dependencies:
apt-get -yy install \
	-o DPkg::Options::="--force-confdef" \
	-o DPkg::Options::="--force-confold" \
	-o DPkg::Options::="--force-overwrite" \
	zynthbox-dependency-ntk zynthbox-dependency-pyliblo zynthbox-dependency-mod-ttymidi \
	zynthbox-dependency-lilv zynthbox-dependency-lvtk-v1 zynthbox-dependency-lvtk-v2 \
	zynthbox-dependency-jalv zynthbox-dependency-aubio zynthbox-dependency-jack-smf-utils \
	zynthbox-dependency-touchosc2midi zynthbox-dependency-jackclient-python zynthbox-dependency-qmidinet \
	zynthbox-dependency-jackrtpmidid zynthbox-dependency-dxsyx zynthbox-dependency-preset2lv2 \
	zynthbox-dependency-qjackctl zynthbox-dependency-njconnect zynthbox-dependency-mutagen \
	zynthbox-dependency-terminado zynthbox-dependency-vl53l0x zynthbox-dependency-mcp4728 \
	zynthbox-dependency-squishbox-sf2
	# zynthbox-dependency-sfizz zynthbox-dependency-setbfree 

# Install jpmidi (MID player for jack with transport sync)
# $ZYNTHIAN_RECIPE_DIR/install_jpmidi.sh

# Install noVNC web viewer
$ZYNTHIAN_RECIPE_DIR/install_noVNC.sh

# Install DT overlays for waveshare displays and others
# $ZYNTHIAN_RECIPE_DIR/install_waveshare-dtoverlays.sh

#************************************************
#------------------------------------------------
# Compile / Install Synthesis Software
#------------------------------------------------
#************************************************

# Install ZynAddSubFX
#$ZYNTHIAN_RECIPE_DIR/install_zynaddsubfx.sh
#Fix soft link to zynbanks, for working as included on zynthian-data repository
ln -s /usr/share/zynaddsubfx /usr/local/share

# Install Fluidsynth & SF2 SondFonts
# Create SF2 soft links
ln -s /usr/share/sounds/sf2/*.sf2 $ZYNTHIAN_DATA_DIR/soundfonts/sf2

# Install Polyphone (SF2 editor)
#$ZYNTHIAN_RECIPE_DIR/install_polyphone.sh

# Install Linuxsampler
#$ZYNTHIAN_RECIPE_DIR/install_linuxsampler_stable.sh

# Install Fantasia (linuxsampler Java GUI)
# $ZYNTHIAN_RECIPE_DIR/install_fantasia.sh

# Setup user config directories
cd $ZYNTHIAN_CONFIG_DIR
mkdir setbfree
ln -s /usr/local/share/setBfree/cfg/default.cfg ./setbfree
cp -a $ZYNTHIAN_DATA_DIR/setbfree/cfg/zynthian_my.cfg ./setbfree/zynthian.cfg

# Install Pianoteq Demo (Piano Physical Emulation)
$ZYNTHIAN_RECIPE_DIR/install_pianoteq_demo.sh

# Install Aeolus (Pipe Organ Emulator)
#apt-get -y install aeolus
# $ZYNTHIAN_RECIPE_DIR/install_aeolus.sh

mkdir /root/Pd
mkdir /root/Pd/externals

#------------------------------------------------
# Install MOD stuff
#------------------------------------------------

#Install MOD-SDK
#$ZYNTHIAN_RECIPE_DIR/install_mod-sdk.sh

#------------------------------------------------
# Install Plugins
#------------------------------------------------
cd $ZYNTHIAN_SYS_DIR/scripts
./setup_plugins_rbpi_bookworm.sh

#------------------------------------------------
# Install Ableton Link Support
#------------------------------------------------
$ZYNTHIAN_RECIPE_DIR/install_hylia.sh
$ZYNTHIAN_RECIPE_DIR/install_pd_extra_abl_link.sh

#************************************************
#------------------------------------------------
# Final Configuration
#------------------------------------------------
#************************************************

# Create flags to avoid running unneeded recipes.update when updating zynthian software
if [ ! -d "$ZYNTHIAN_CONFIG_DIR/updates" ]; then
	mkdir "$ZYNTHIAN_CONFIG_DIR/updates"
fi

# Run configuration script before ending
$ZYNTHIAN_SYS_DIR/scripts/update_zynthian_sys.sh

#************************************************
#------------------------------------------------
# End & Clean
#------------------------------------------------
#************************************************

#Block MS repo from being installed
apt-mark hold raspberrypi-sys-mods
touch /etc/apt/trusted.gpg.d/microsoft.gpg

# Clean

rm -rf /root/.gitconfig # Remove github personal access token
# rm -f "$ZYNTHIAN_PLUGINS_DIR/lv2" # Remove lv2 symbolic link

apt-get -y autoremove # Remove unneeded packages
if [[ "$ZYNTHIAN_SETUP_APT_CLEAN" == "yes" ]]; then # Clean apt cache (if instructed via zynthian_envars.sh)
    apt-get clean
fi
