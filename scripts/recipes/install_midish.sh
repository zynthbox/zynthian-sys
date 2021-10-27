# midish

cd $ZYNTHIAN_SW_DIR
git clone https://github.com/ratchov/midish.git

cd midish
./configure
make -j$(nproc)
make install
make clean
cd ..
