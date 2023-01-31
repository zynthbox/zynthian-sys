#!/bin/bash

cd $ZYNTHIAN_SW_DIR
if [ ! -d "ntk" ]; then
	wget https://github.com/zynthbox/dependencies/releases/download/v0.5/ntk.zip
	unzip ntk.zip
	rm ntk.zip
	cd ntk
	./waf configure
	./waf
	./waf install
	cd ..
fi
