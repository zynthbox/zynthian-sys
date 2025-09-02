#!/bin/bash

source "$ZYNTHIAN_SYS_DIR/config/zynthian_envars.sh"

echo "Regenerating cache LV2 ..."
cd $ZYNTHIAN_UI_DIR/zyngine
python3 ./zynthian_lv2.py
