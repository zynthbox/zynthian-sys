#!/bin/bash

VERSION="3.21.1"

# riban LV2 plugins
cd $ZYNTHIAN_sw_DIR

if [ -d cmake-$VERSION ]; then
	rm -rf cmake-$VERSION
fi

apt-get -y install libssl-dev

wget https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz
tar xfvz cmake-$VERSION.tar.gz
rm -f cmake-$VERSION.tar.gz
cd cmake-$VERSION

./bootstrap --prefix=/usr/local
make -j$(nproc)
make install

rm -rf cmake-$VERSION
