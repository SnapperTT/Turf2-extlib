Sysroots for toolchains go here


Known issues for RPi5:
* Arch gcc version does not match c++
* libstdc++.so symlink does not exist in `/usr/lib/aarch64-linux-gnu/`. You need to include `./rpi_arm64/usr/lib/gcc/aarch64-linux-gnu/12/` in your linking search path
* libm.so points to absolute path. Change symlink from -> `/lib/aarch64-linux-gnu/libm.so.6` to `lib/aarch64-linux-gnu/libm.so.6`
* zlib is missing. Set SYSROOT in to the fetched sysroot directory

```
cd /tmp
wget https://zlib.net/zlib-1.3.1.tar.gz
tar xf zlib-1.3.1.tar.gz
cd zlib-1.3.1

# Cross-compile
CC=aarch64-linux-gnu-gcc \
AR=aarch64-linux-gnu-ar \
RANLIB=aarch64-linux-gnu-ranlib \
CFLAGS="--sysroot=$SYSROOT" \
LDFLAGS="-L$SYSROOT/lib/aarch64-linux-gnu"
./configure --prefix=$SYSROOT/usr

make -j
make install
```
