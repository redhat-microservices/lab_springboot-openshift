#!/usr/bin/env bash

cd build
PROJECT_DIR=cdservice

if [ -d $PROJECT_DIR ]; then
 rm -rf $PROJECT_DIR
fi

export CURRENT=$(pwd)
export FORGE_PATH=~/Temp/dev/forge/bin
$FORGE_PATH/forge -e "run ../scripts/cdstore-forge.fsh"
cd ..