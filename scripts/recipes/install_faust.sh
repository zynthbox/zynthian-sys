#!/bin/bash

# Faust
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/grame-cncm/faust.git
cd faust
git submodule update --init
make -j$(nproc)
make install
make clean
