# Dependancy Builder for Turf 2
[Turf 2](https://store.steampowered.com/app/1067420/Turf2/) is the at time of writing unreleased sequal to [Voxel Turf](https://store.steampowered.com/app/404530/Voxel_Turf/)

This is *not* the source code for the game, but it is a utility for compling and porting it. It downloads and compiles all the libraries that Turf 2 depends on and compiles a small dummy program. If this dummy program runs on a target architecture *then* it is most likely that Turf 2 will run on it.

## Building
Assumes that you are building FROM a Linux machine (or linux subsystem on windows). Only linux has been tested.

To build for linux with `gcc` for x86-64:
`make linux`

To cross compile with `x86_64-w64-mingw32-gcc` for windows x86-64
`make TARGET_OS=win`

To cross compile with clang for osx (requires [osxcross](https://github.com/tpoechtrager/osxcross))
osx x86-64:
`make TARGET_OS=osx`

osx arm64:
`make TARGET_OS=osx-arm64`

osx arm64e:
`make TARGET_OS=osx-arm64e`

If you wish to add another platform edit the "Platform Settings" section of `common.mk`

## Tests
`make tests` with your desired `TARGET_OS`. They will be built to the lib 

### t2_hello_world
Tests linking. Just prints a message then closes

### t2_windowing
Tests initialising a window

