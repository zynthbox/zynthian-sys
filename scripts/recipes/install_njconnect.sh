#!/bin/bash

# njconnect
cd $ZYNTHIAN_SW_DIR
svn checkout https://svn.code.sf.net/p/njconnect/code/trunk njconnect
cd njconnect
make -j$(nproc)
make install
make clean
cd ..
