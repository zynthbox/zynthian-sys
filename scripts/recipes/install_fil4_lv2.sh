#!/bin/bash

cd $ZYNTHIAN_PLUGINS_SRC_DIR
if [ -d "fil4.lv2" ]; then
	rm -rf "fil4.lv2"
fi

export OPTIMIZATIONS=""

git clone git://github.com/x42/fil4.lv2.git
cd fil4.lv2
make -j$(nproc) submodules
make -j$(nproc)
make install PREFIX=/usr/local
cd ..

rm -rf "fil4.lv2"
