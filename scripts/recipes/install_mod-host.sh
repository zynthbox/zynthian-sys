#!/bin/bash

# Mod-Host
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/moddevices/mod-host.git
cd mod-host

# if [[ -n $MOD_HOST_GITSHA ]]; then
# 	git branch -f zynthian $MOD_HOST_GITSHA
# 	git checkout zynthian
# fi

git checkout a8a0a2eed4b11d46118367006f4ba1f429404c67

#patch -p1 <"${HOME}/zynthian/zynthian-recipe/mod-host.patch.txt"
make -j$(nproc)
make install
make clean
