#!/usr/bin/env bash
PWD=`pwd`
mkdir -p $PWD/rpi_arm64
bash $PWD/../scripts/fetch_arm_sysroot.sh 1 rpi_arm64

