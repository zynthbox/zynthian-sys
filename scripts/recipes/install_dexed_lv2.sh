#!/bin/bash

cd $ZYNTHIAN_PLUGINS_SRC_DIR
git clone https://github.com/dcoredump/dexed.lv2
cd dexed.lv2/src
make -j$(nproc)
make install
cd ../..
