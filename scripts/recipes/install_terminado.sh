#!/bin/bash

cd $ZYNTHIAN_SW_DIR
if [ -d "terminado" ]; then
	rm -rf "terminado"
fi

# The next command prints an error that i don't know how to avoid, so i send the error to /dev/null for avoid breaking nightly builds
pip3 install tornado_xstatic 2>/dev/null
pip3 install xstatic 2>/dev/null
pip3 install XStatic_term.js 2>/dev/null

git clone https://github.com/jupyter/terminado.git
cd terminado
git checkout ce1f6a1e7e2d4fc72d10cd5bb7f821996679c5d7
git submodule update --init --recursive
python3 ./setup.py install
cd ..

#rm -rf "terminado"
