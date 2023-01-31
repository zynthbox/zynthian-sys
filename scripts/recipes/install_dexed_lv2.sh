#!/bin/bash

cd $ZYNTHIAN_PLUGINS_SRC_DIR
git clone https://github.com/dcoredump/dexed.lv2
cd dexed.lv2/src

# Remove -mabi and -mcmodel parameters which were causing builds to fail
sed -i -E 's/-mabi\S*|-mcmodel\S*//g' Makefile

make -j$(nproc)
make install
cd ../..
