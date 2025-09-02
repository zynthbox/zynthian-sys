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

source /zynthian/zynthian-sys/config/zynthian_envars.sh

export DEBIAN_FRONTEND=noninteractive

#------------------------------------------------
# Set default config
#------------------------------------------------

[ -n "$ZYNTHIAN_INCLUDE_RPI_UPDATE" ] || ZYNTHIAN_INCLUDE_RPI_UPDATE=no
[ -n "$ZYNTHIAN_INCLUDE_PIP" ] || ZYNTHIAN_INCLUDE_PIP=yes
[ -n "$ZYNTHIAN_CHANGE_HOSTNAME" ] || ZYNTHIAN_CHANGE_HOSTNAME=yes

#------------------------------------------------
# Update System & Firmware
#------------------------------------------------

# Hold kernel version 
#apt-mark hold raspberrypi-kernel

# Update System
apt-get -y update --allow-releaseinfo-change

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
# wget https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb
# sudo dpkg -i deb-multimedia-keyring_2024.9.1_all.deb
# rm -f deb-multimedia-keyring_2024.9.1_all.deb

# KXStudio
# wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_11.1.0_all.deb
# dpkg -i kxstudio-repos_11.1.0_all.deb
# rm -f kxstudio-repos_11.1.0_all.deb

# Zynthbox
if [ ! -z "$ZYNTHIANOS_ZYNTHBOX_REPO_KEY_URL" -a ! -z "$ZYNTHIANOS_ZYNTHBOX_REPO_SOURCELINE" ]; then
	curl -fsSL https://repo.zynthbox.io/repo_key.pub | gpg --dearmor | tee /etc/apt/trusted.gpg.d/zynthbox.gpg
	echo "$ZYNTHIANOS_ZYNTHBOX_REPO_SOURCELINE" > /etc/apt/sources.list.d/zynthbox.list
	echo "deb http://repo.zynthbox.io/kxstudio bookworm main" > /etc/apt/sources.list.d/zynthbox-kxstudio.list
	echo "deb http://repo.zynthbox.io/deb-multimedia bookworm main" > /etc/apt/sources.list.d/zynthbox-deb-multimedia.list
fi

apt-get -y update -oAcquire::AllowInsecureRepositories=true
apt-get -y dist-upgrade
apt-get -y autoremove

#------------------------------------------------
# Install Required Packages
#------------------------------------------------

# System
apt-get -y remove --purge isc-dhcp-client triggerhappy logrotate dphys-swapfile
SYSTEM_PACKAGES="systemd avahi-daemon dhcpcd-dbus usbutils udisks2 udevil exfatprogs \
xinit xserver-xorg-video-fbdev x11-xserver-utils xinput libgl1-mesa-dri tigervnc-standalone-server \
xdotool cpufrequtils wpasupplicant wireless-tools iw dnsmasq firmware-brcm80211 firmware-atheros \
firmware-realtek atmel-firmware firmware-misc-nonfree shiki-colors-xfwm-theme fonts-freefont-ttf \
x11vnc xserver-xorg-input-evdev"

# CLI Tools
CLI_TOOLS_PACKAGES="raspi-config psmisc tree joe nano vim p7zip-full i2c-tools \
fbi scrot mpg123  mplayer xloadimage imagemagick fbcat abcmidi evtest libts-bin \
gpiod libgpiod-dev"

PYTHON_PACKAGES="python3 python3-dev cython3 python3-cffi python3-dbus python3-mpmath python3-pil python3-pip \
python3-setuptools python3-numpy-dev python3-evdev 2to3 python-is-python3 python3-tk python3-pil.imagetk"

apt-get -y -o Dpkg::Options::="--force-confdef" install $SYSTEM_PACKAGES $CLI_TOOLS_PACKAGES $PYTHON_PACKAGES

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
LIBS_PACKAGES="libfftw3-dev libmxml-dev zlib1g-dev fluid libfltk1.3-dev libfltk1.3-compat-headers \
libncurses5-dev liblo-dev dssi-dev libjpeg-dev libxpm-dev libcairo2-dev libglu1-mesa-dev \
libasound2-dev dbus-x11 jackd2 libjack-jackd2-dev a2jmidid libffi-dev fontconfig-config \
libfontconfig1-dev libxft-dev libexpat-dev libglib2.0-dev libgettextpo-dev libsqlite3-dev \
libglibmm-2.4-dev libeigen3-dev libsndfile-dev libsamplerate-dev libarmadillo-dev libreadline-dev \
lv2-c++-tools libxi-dev libgtk2.0-dev libgtkmm-2.4-dev liblrdf-dev libboost-system-dev libzita-convolver-dev \
libzita-resampler-dev fonts-roboto libxcursor-dev libxinerama-dev mesa-common-dev libgl1-mesa-dev \
libfreetype6-dev  libswscale-dev  qtbase5-dev qtdeclarative5-dev libcanberra-gtk-module \
libcanberra-gtk3-module libxcb-cursor-dev libgtk-3-dev libxcb-util0-dev libxcb-keysyms1-dev libxcb-xkb-dev \
libxkbcommon-x11-dev libssl-dev libtag1-dev"
EXTRA_PACKAGES="jack-midi-clock midisport-firmware"

apt-get -y --no-install-recommends install $BUILD_TOOLS_PACKAGES $AV_LIBS_PACKAGES $LIBS_PACKAGES $EXTRA_PACKAGES

# Setup Python venv
cd "$ZYNTHIAN_DIR"
python3 -m venv venv --system-site-packages
source "$ZYNTHIAN_DIR/venv/bin/activate"

PIP3_PACKAGES="tornado tornado_xstatic tornadostreamform websocket-client jsonpickle oyaml psutil pexpect requests mido python-rtmidi python-magic XStatic-term.js"
ZYNTHBOX_PIP3_PACKAGES="soundfile pytaglib==2.1.0 pynput adafruit-circuitpython-neopixel-spi"
MOD_UI_PIP3_PACKAGES="pyserial pystache aggdraw pycrypto"
pip3 install --upgrade pip
pip3 install $PIP3_PACKAGES $ZYNTHBOX_PIP3_PACKAGES $MOD_UI_PIP3_PACKAGES

ZYNTHBOX_OTHER_DEPENDENCIES="zynthbox-dependency-mod-host zynthbox-dependency-mod-browsepy zynthian-data zynthbox-dependency-mod-ui plasma-framework-zynthbox"

UPDATABLE_PACKAGES="$(cat $ZYNTHIAN_SYS_SCRIPTS_DIR/updatable_packages.list)"

# Install ZynthboxQML and its dependencies
apt-get -y --allow-unauthenticated install $UPDATABLE_PACKAGES $ZYNTHBOX_OTHER_DEPENDENCIES

#************************************************
#------------------------------------------------
# Create Zynthian Directory Tree & 
# Install Zynthian Software from repositories
#------------------------------------------------
#************************************************

# Create needed directories
mkdir "$ZYNTHIAN_DIR"
if [ ! -d $ZYNTHIAN_CONFIG_DIR ]; then
    # $ZYNTHIAN_CONFIG_DIR either exists and is not a directory or does not exists. Try to remove first before creating dir
    rm -rf $ZYNTHIAN_CONFIG_DIR
    mkdir -p $ZYNTHIAN_CONFIG_DIR
fi
mkdir "$ZYNTHIAN_SW_DIR"

# Create needed directories
mkdir -p "$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
mkdir -p "$ZYNTHIAN_DATA_DIR/soundfonts/gig"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/presets/lv2"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/presets/zynaddsubfx/XMZ"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/presets/mod-ui/pedalboards"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/presets/puredata/generative"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/presets/puredata/synths"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sf2"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sfz"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/soundfonts/gig"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/snapshots/000"
#mkdir -p "$ZYNTHIAN_MY_DATA_DIR/capture"
mkdir -p "$ZYNTHIAN_MY_DATA_DIR/preset-favorites"
mkdir -p "$ZYNTHIAN_PLUGINS_DIR/lv2"

# Copy default snapshots
cp -a $ZYNTHIAN_SYS_DIR/snapshots/default.zss $ZYNTHIAN_MY_DATA_DIR/snapshots/

#************************************************
#------------------------------------------------
# System Adjustments
#------------------------------------------------
#************************************************

#Change Hostname
if [ "$ZYNTHIAN_CHANGE_HOSTNAME" == "yes" ]; then
    echo "zynthbox" > /etc/hostname
    sed -i -e "s/127\.0\.1\.1.*$/127.0.1.1\tzynthbox/" /etc/hosts
fi

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
systemctl disable apt-daily-upgrade.timer
systemctl disable fwupd-refresh.timer
systemctl disable NetworkManager.service
systemctl disable vncserver0.service
systemctl disable vncserver1.service
systemctl disable novnc0.service
systemctl disable novnc1.service
systemctl --user disable pulseaudio.service
systemctl --user disable pulseaudio-x11.service
systemctl enable backlight
systemctl enable cpu-performance
systemctl enable wifi-setup
systemctl enable jack2
systemctl enable mod-ttymidi
systemctl enable a2jmidid
systemctl enable zynthbox-qml
systemctl enable zynthian-webconf
systemctl enable zynthian-webconf-fmserver
systemctl enable rfkill-unblock-all

# Setup loading of Zynthian Environment variables ...
echo "source $ZYNTHIAN_SYS_DIR/zynthian-sys/config/zynthian_envars.sh" >> /root/.bashrc
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
	aubio-tools libaubio-dev lilv-utils liblilv-dev  python3-jack-client python3-liblo pyliblo-utils \
	python3-mutagen python3-terminado python3-ujson qjackctl novnc zynthbox-dependency-dxsyx zynthbox-dependency-faust \
	zynthbox-dependency-lvtk-v1 zynthbox-dependency-mod-browsepy \
	zynthbox-dependency-mod-host zynthbox-dependency-mod-ttymidi zynthbox-dependency-mod-ui \
	zynthbox-dependency-njconnect zynthbox-dependency-ntk zynthbox-dependency-preset2lv2 \
	zynthbox-dependency-python3-lilv zynthbox-dependency-sfizz zynthbox-dependency-squishbox-sf2 zynthbox-dependency-touchosc2midi \
	zynthbox-dependency-xmodits

# zynthbox-dependency-lvtk-v2 : v2 fails to install as it tries to overwrite files with the same name as v1

#************************************************
#------------------------------------------------
# Compile / Install Synthesis Software
#------------------------------------------------
#************************************************

#Fix soft link to zynbanks, for working as included on zynthian-data repository
ln -s /usr/share/zynaddsubfx /usr/local/share

# Install Fluidsynth & SF2 SondFonts
# Create SF2 soft links
ln -s /usr/share/sounds/sf2/*.sf2 $ZYNTHIAN_DATA_DIR/soundfonts/sf2

# If default-GM exists then remove.
# default-GM.sf2 is replaced by FluidR3Mono.sf3 (added in zynthian-soundfonts package) because of reduced size of sf3 plugins
if [ -e "$ZYNTHIAN_DATA_DIR/soundfonts/sf2/default-GM.sf2" ]; then
  rm $ZYNTHIAN_DATA_DIR/soundfonts/sf2/default-GM.sf2
fi

# Setup user config directories
cd $ZYNTHIAN_CONFIG_DIR
mkdir setbfree
ln -s /usr/local/share/setBfree/cfg/default.cfg ./setbfree
cp -a $ZYNTHIAN_DATA_DIR/setbfree/cfg/zynthian_my.cfg ./setbfree/zynthian.cfg

# Install Pianoteq Demo (Piano Physical Emulation)
export PIANOTEQ_INSTALL_FILENAME="pianoteq_stage_linux_trial_v754.7z"
cd $ZYNTHIAN_SW_DIR
wget http://download.zynthian.org/$PIANOTEQ_INSTALL_FILENAME
$ZYNTHIAN_SYS_DIR/scripts/install_pianoteq_binary.sh "$ZYNTHIAN_SW_DIR/$PIANOTEQ_INSTALL_FILENAME"
rm -f "$ZYNTHIAN_SW_DIR/$PIANOTEQ_INSTALL_FILENAME"

$ZYNTHIAN_SYS_DIR/scripts/update_zynthian_sys.sh

mkdir /root/Pd
mkdir /root/Pd/externals

#------------------------------------------------
# Install Plugins
#------------------------------------------------
cd $ZYNTHIAN_SYS_DIR/scripts

# Plugins not working :
# geonkick
# drumgizmo
# drumkv1 : It is not directly usable. Needs access to UI to create/load samples

apt-get -yy install \
    abgate adlplug aeolus ams-lv2 amsynth arctican-plugins-lv2 artyfx bchoppr beatslash-lv2 blop-lv2 \
	bsequencer bshapr bslizr calf-plugins caps-lv2 cv-lfo-blender-lv2 distrho-plugin-ports-lv2 \
	dpf-plugins dragonfly-reverb drmr drowaudio-plugins-lv2 easyssp-lv2 \
	eq10q fabla fluidsynth fluid-soundfont-gm fluid-soundfont-gs g2reverb  gigtools gxplugins \
	gxvoxtonebender helm hybridreverb2 infamous-plugins invada-studio-plugins-lv2 jalv juce-opl-lv2 \
	juced-plugins-lv2 klangfalter-lv2 linuxsampler lsp-plugins lufsmeter-lv2 luftikus-lv2 lv2vocoder \
	mod-cv-plugins mod-distortion mod-pitchshifter mod-utilities moony.lv2 noise-repellent obxd-lv2 \
	openmpt123 oxefmsynth padthv1-lv2 pitcheddelay-lv2 pizmidi-plugins regrader rubberband-lv2 safe-plugins \
	samplv1-lv2 setbfree shiro-plugins sorcer surge synthv1-lv2 tal-plugins-lv2 tap-lv2 temper-lv2 \
	teragonaudio-plugins-lv2 timgm6mb-soundfont vitalium-lv2 wolf-shaper wolf-spectrum wolpertinger-lv2 \
	zam-plugins zlfo zynaddsubfx \
	zynthbox-plugin-aether-reverb zynthbox-plugin-airwin2rack zynthbox-plugin-alo zynthbox-plugin-bolliedelay \
	zynthbox-plugin-fluidplug zynthbox-plugin-foo-yc20 zynthbox-plugin-guitarix zynthbox-plugin-gula \
	zynthbox-plugin-gxdenoiser2 zynthbox-plugin-gxdistortionplus zynthbox-plugin-gxswitchlesswah \
	zynthbox-plugin-mclk zynthbox-plugin-midi-display zynthbox-plugin-miniopl3 zynthbox-plugin-mod-arpeggiator \
	zynthbox-plugin-mod-cabsim-ir-loader zynthbox-plugin-punk-console zynthbox-plugin-qmidiarp \
	zynthbox-plugin-raffo zynthbox-plugin-remid zynthbox-plugin-sooperlooper-lv2-plugin \
	zynthbox-plugin-sosynth zynthbox-plugin-stereo-mixer zynthbox-plugin-string-machine zynthbox-plugin-swh \
	zynthbox-plugin-triceratops zynthbox-plugin-vl1 zynthbox-plugin-ykchorus zynthbox-soundfonts

# Stop & disable systemd fluidsynth service
systemctl stop --user fluidsynth.service
systemctl mask --user fluidsynth.service

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

# Disable the "ssh may not work" banner
rm -f /etc/ssh/sshd_config.d/rename_user.conf

#Block MS repo from being installed
apt-mark hold raspberrypi-sys-mods
touch /etc/apt/trusted.gpg.d/microsoft.gpg

# Create build_info.txt
echo "Build Version: $(cat $ZYNTHIAN_SYS_DIR/Z1_VERSION.txt)" >> /zynthian/build_info.txt
echo "Build Date: $(date +'%d-%b-%Y')" >> /zynthian/build_info.txt

# Clean
apt-get -y autoremove # Remove unneeded packages
apt-get clean
