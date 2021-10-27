#!/bin/bash

cd $ZYNTHIAN_SW_DIR
if [ -d "aubio" ]; then
	rm -rf "aubio"
fi
git clone https://github.com/aubio/aubio.git
cd aubio
sed -i -- 's/gpg --verify/#gpg --verify/' ./scripts/get_waf.sh 
make -j$(nproc)
cp -fa ./build/src/libaubio* /usr/local/lib
cp -fa ./build/examples/aubiomfcc /usr/local/bin
cp -fa ./build/examples/aubionotes /usr/local/bin
cp -fa ./build/examples/aubioonset /usr/local/bin
cp -fa ./build/examples/aubiopitch /usr/local/bin
cp -fa ./build/examples/aubioquiet /usr/local/bin
cp -fa ./build/examples/aubiotrack /usr/local/bin
gpgconf --kill gpg-agent

cd ..
rm -rf "aubio"
