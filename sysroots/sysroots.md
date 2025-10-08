Sysroots for toolchains go here


Known issues for RPi5:
* Dev headers are missing. `./install_sysroot_packages.sh rpi_arm64 --install libraspberrypi-dev raspberrypi-kernel-headers libsdl3-dev`
* egl lacks symlinks: `cd rpi_arm64/usr/lib/aarch64-linux-gnu/ && ln -s libEGL.so.1 libEGL.so && ln -s libGLESv2.so.2 libGLESv2.so`

Trixie:
* ` libraspberrypi-dev` no longer exists, needs package `userland`
