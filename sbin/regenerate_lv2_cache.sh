#!/bin/bash

if [ -d "$ZYNTHIAN_CONFIG_DIR" ]; then
	source "$ZYNTHIAN_CONFIG_DIR/zynthian_envars.sh"
else
	source "$ZYNTHIAN_SYS_DIR/scripts/zynthian_envars.sh"
fi

echo "Regenerating cache LV2 ..."
cd $ZYNTHIAN_UI_DIR/zyngine
python3 ./zynthian_lv2.py
