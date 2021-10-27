#!/bin/bash

# qmidinet
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/rncbc/qmidinet.git
cd qmidinet
./autogen.sh
./configure
make -j$(nproc)
make install
cd ..
