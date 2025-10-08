#!/usr/bin/env bash

# By default download `fetch_arm_sysroot.sh 1 rpi_arm64`
# if you provide an argument (eg build_rpi_sysroot.sh pi.img) it'll extract the provided image file instead
TARGET=${1:-1}
PWD=`pwd`
mkdir -p $PWD/rpi_arm64
bash $PWD/../scripts/fetch_arm_sysroot.sh $TARGET rpi_arm64
cd $PWD/rpi_arm64 && ln -s usr/lib lib
