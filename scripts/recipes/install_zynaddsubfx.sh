#!/bin/bash

# Don't use environment optimizations
#unset CFLAGS
#unset CXXFLAGS
#unset LV2_PATH

if [[ ${MACHINE_HW_NAME} =~ [armv7l] ]]; then
	export CFLAGS="-mfpu=neon-vfpv4 -mfloat-abi=hard -mvectorize-with-neon-quad"
	export CXXFLAGS=$CFLAGS
fi


cd $ZYNTHIAN_SW_DIR
if [ -d "zynaddsubfx" ]; then
	rm -rf "zynaddsubfx"
fi

git clone https://github.com/fundamental/zynaddsubfx.git
cd zynaddsubfx
mkdir build
cd build
cmake ..
#ccmake .
# => delete "-msse -msse2 -mfpmath=sse" 
# => optimizations: -pipe -mfloat-abi=hard -mfpu=neon-vfpv4 -mvectorize-with-neon-quad -funsafe-loop-optimizations -funsafe-math-optimizations
# => optimizations that doesn't work: -mcpu=cortex-a7 -mtune=cortex-a7

sed -i -- "s/-march=armv7-a -mfloat-abi=hard -mfpu=neon -mcpu=cortex-a9 -mtune=cortex-a9 -pipe -mvectorize-with-neon-quad -funsafe-loop-optimizations/$CFLAGS $CFLAGS_UNSAFE/" CMakeCache.txt
cmake ..

# Compile & Install
make -j$(nproc)
make install

#Create soft link to zynbanks => It's included in the data repository
#ln -s $ZYNTHIAN_SW_DIR/zynaddsubfx/instruments/banks $ZYNTHIAN_DATA_DIR/zynbanks

rm -rf "$ZYNTHIAN_SW_DIR/zynaddsubfx"
