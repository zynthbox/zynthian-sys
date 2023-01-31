#!/bin/bash

# Remove -mabi and -mcmodel parameters which were causing builds to fail
TMPCFLAGS=$(echo "$CXXFLAGS" | sed 's/-mabi\S*//g' | sed 's/-mcmodel\S*//g')

cd $ZYNTHIAN_PLUGINS_SRC_DIR
git clone https://github.com/dcoredump/dexed.lv2
cd dexed.lv2/src
CFLAGS="$TMPCFLAGS" CXXFLAGS="$TMPCFLAGS" make -j$(nproc)
make install
cd ../..
