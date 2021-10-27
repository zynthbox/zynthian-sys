#!/bin/bash

# install_mod-caps.sh
cd $ZYNTHIAN_PLUGINS_SRC_DIR

if [ -d "caps-lv2" ]; then
	rm -rf "caps-lv2"
fi

#git clone https://github.com/BlokasLabs/caps-lv2.git
git clone https://github.com/moddevices/caps-lv2

cd caps-lv2
make -j$(nproc)
cp -R plugins/* $ZYNTHIAN_PLUGINS_DIR/lv2
make clean

cd ..
rm -rf "caps-lv2"
