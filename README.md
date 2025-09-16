# Dependancy Builder for Turf 2
[Turf 2](https://store.steampowered.com/app/1067420/Turf2/) ([turf2.net](https://www.turf2.net)) is the at time of writing unreleased sequal to [Voxel Turf](https://store.steampowered.com/app/404530/Voxel_Turf/) ([voxelturf.net](https://www.voxelturf.net))

This is *not* the source code for the game, but it is a utility for compling and porting it. It downloads and compiles all the libraries that Turf 2 depends on and compiles a small dummy program. If `t2_windowing` runs on a target architecture *then* it is most likely that Turf 2 will run on it.


## Building
Assumes that you are building FROM a Linux machine (or linux subsystem on windows). *Only linux x64 has been tested and will be supported*.


Make sure that you have the following installed: `git`, `git-lfs`, `wget`, `cmake`. If there are other programs you need please list them here.


To build for linux with `gcc` for x86-64:

`make linux`

To cross compile with `x86_64-w64-mingw32-gcc` for windows x86-64:

`make TARGET_OS=win`

To cross compile with clang for osx (requires [osxcross](https://github.com/tpoechtrager/osxcross)). Instructions for installing `osxcross` are in the `scripts` directory. 
osx x86-64:

`make TARGET_OS=osx`
(x86 mac no longer supported, bgfx no longer supports this target)
osx arm64:

`make TARGET_OS=osx-arm64`

osx arm64e:

`make TARGET_OS=osx-arm64e`

linux arm:

Requires Arch Linux package `aarch64-linux-gnu-gcc` for the compiler.

`make TARGET_OS=linux-arm64`

If you wish to add another platform edit the "Platform Settings" section of `common.mk` and submit a PR.

If you want to build multiple targets at the same time it is recommended that you `make all-sources` to download and patch the all the libraries then run `make TARGET_OS=XXX` and `make TARGET_OS=YYY` simultaneously.


## Tests
`make tests` with your desired `TARGET_OS`. They will be built to the `lib_XXX_YYY` directory for your target platform and architecture.

### t2_hello_world
Tests linking. Just prints a message then closes

### t2_windowing
Tests initialising a window with BGFX and SDL



## Supported Platforms
As of 2024: linux (x64), windows (x64), osx (x64, arm64, arm64e)


## License
LGPL. If you want to use my build system or patches to bootstrap an engine for your project (even commercial) that's fine.
