# Cross compiling to mac:
- get xcode from apple website (https://xcodereleases.com) (login to apple's website and refresh page)
- get osxcross (https://github.com/tpoechtrager/osxcross) and run the scripts (Run ./tools/gen_sdk_package_pbzx.sh <xcode>.xip full path for xcode file)
- move resulting tar.gz into /tarballs/
- move everything to /usr/osxcross
- build (SDK_VERSION=14 TARGET_DIR=/usr/osxcross/ ./build.sh)
- add /usr/osxcross/bin/ to PATH by editing .bashrc (PATH=\$PATH:/usr/osxcross/bin)
- restart bash or reboot so that the PATH variable is updated" 
- compile gcc (SDK_VERSION=14 TARGET_DIR=/usr/osxcross DISABLE_LTO_SUPPORT=1 ./build_gcc.sh)

!!! Use aarch64-apple-darwin23-* instead of arm64-* when dealing with Automake !!!
!!! CC=aarch64-apple-darwin23-clang ./configure --host=aarch64-apple-darwin23 !!!
!!! CC="aarch64-apple-darwin23-clang -arch arm64e" ./configure --host=aarch64-apple-darwin23 !!!

