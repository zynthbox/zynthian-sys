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
          zynthbox-soundfonts"
# REMOVED_PACKAGES="zynthbox-theme-alt"

###
# Running this function will install/update the listed packages
# and also will remove the packages removed in the current image
###
do_migration () {
    echo "### Installing packages"

    # Keeping this commented since new image will be used which will not have obsolete packages.
    # However if in future we need to remove obsolete packages, we can uncomment this section.
    # Remove obsolete packages
    # if [[ -n "$REMOVED_PACKAGES" ]]; then
    #     echo "### Removing obsolete packages"
    #     apt-get -yy purge $REMOVED_PACKAGES
    # fi

    # Update all packages
    apt-get -yy install \
        -o DPkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold" \
        -o DPkg::Options::="--force-overwrite" \
        $PACKAGES
}

# Call the do_migration function
do_migration