#!/bin/bash
#
# Update Script for Zynthbox
# License: GPLv3

# Source envars to switch to venv
if [ -f /zynthian/zynthian-sys/config/zynthian_envars.sh ]; then
    # Load new envars file from zynthian-sys if it exists
    source /zynthian/zynthian-sys/config/zynthian_envars.sh
elif [ -f /zynthian/config/zynthian_envars.sh ]; then
    # Load old envars file from config if it exists
    source /zynthian/config/zynthian_envars.sh
fi

DEBIAN_FRONTEND=noninteractive
PACKAGES="zynthbox-qml \
          libzynthbox \
          zynthbox-bootsplash \
          zyncoder \
          zynthian-webconf \
          plasma-framework \
          qml-module-zynthbox \
          qml-style-zynthbox \
          zynthian-sys \
          zynthbox-plugin-raffo \
          zynthbox-docs sunshine \
          sonobus \
          zynthbox-plugin-fabla \
          zynthbox-plugin-gxplugins \
          zynthbox-theme \
          zynthbox-virtualkeyboard-theme \
          pipewire-jack \
          wireplumber \
          zynthbox-soundfonts \
          qml-module-qtquick-particles2 \
          libqt5quickparticles5 \
          libqt5x11extras5 \
          libkf5iconthemes5 \
          audiocontrol \
          emu-tools"
# REMOVED_PACKAGES="zynthbox-theme-alt"

###
# Running this function will install/update the listed packages
# and also will remove the packages removed in the current image
###
do_upgrade () {
    echo "### Installing packages"

    # Keeping this commented since new image will be used which will not have obsolete packages.
    # However if in future we need to remove obsolete packages, we can uncomment this section.
    # Remove obsolete packages
    # if [[ -n "$REMOVED_PACKAGES" ]]; then
    #     echo "### Removing obsolete packages"
    #     apt-get -yy purge $REMOVED_PACKAGES
    # fi

    # Update nodejs version to 22.x LTS from nodesource if version is not 22.x
    if node --version | grep -vq "v22"; then
        # Node version is not v22.x. Upgrade nodejs
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        apt-get install -yy nodejs
        npm install -g pnpm
    fi

    # Update all packages
    apt-get -yy install \
        -o DPkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold" \
        -o DPkg::Options::="--force-overwrite" \
        $PACKAGES
}

# Execute argument to run one of the above functions
"$@"
