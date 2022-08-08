#!/bin/bash

# qmidinet
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/rncbc/qmidinet.git
cd qmidinet
git checkout 647f7a1ec0fa87fc3bd0fa422cddaf211b3233a7
git submodule update --init --recursive
./autogen.sh
./configure
make -j$(nproc)
make install
cd ..
