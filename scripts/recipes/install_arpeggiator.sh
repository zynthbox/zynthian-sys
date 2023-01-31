#!/bin/bash

# Remove -mtune parameters which were causing builds to fail
TMPCFLAGS=$(echo "$CXXFLAGS" | sed 's/-mtune\S*//g')

cd $ZYNTHIAN_PLUGINS_SRC_DIR
if [ -d "arpeggiator_LV2" ]; then
	rm -rf "arpeggiator_LV2"
fi

git clone https://github.com/BramGiesen/arpeggiator_LV2.git
cd arpeggiator_LV2
sed -i 's#^PREFIX  := /usr#PREFIX  := #' Makefile
sed -i 's#^LIBDIR  := $(PREFIX)/lib#LIBDIR  := #' Makefile
sed -i "s#^DESTDIR :=#DESTDIR := $ZYNTHIAN_PLUGINS_DIR#" Makefile
CFLAGS="$TMPCFLAGS" CXXFLAGS="$TMPCFLAGS" make -j$(nproc)
make install
cd ..

rm -rf "arpeggiator_LV2"
