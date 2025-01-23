#######################################################################################
# Platform Settings:
# IF YOU WANT TO ADD YOUR OWN PLATFORM copy the the settings here and add to the "ifeq/endif" section below
#
CONFIGURE_BUILD=x86_64-pc-linux

#######################################################################################
# Default target (linux x86)
PLATFORM_IS_SUPPORTED=FALSE

ifeq ($(TARGET_OS),linux)
  PLATFORM_IS_SUPPORTED=TRUE
endif

TARGET=
CC=gcc
CXX=g++
CXXFLAGS=-std=c++17
AR=ar
LD=ld
RANLIB=ranlib
CMAKE_TOOLCHAIN=
CMAKE=cmake
CONFIGURE=
LIB=$(EXTLIB)/lib_lin_x64/


LUA_MAKE=linux MYCFLAGS=-g
LUAJIT_MAKE=
BGFX_MAKE=make -s linux-gcc CC='$(CC)' CXX='$(CXX)' CXX_FLAGS='$(CXXFLAGS)' AR='$(AR)'

# T2 flags
T2_SDL2_CONFILG_LIBS=`sdl2-config --libs`
T2_CXX_FLAGS=
T2_TARGET_SPECIFIC_LINK_FLAGS=-ldl -lGL -lX11  -Wl,-R./ -Wl,-R./build/
T2_LD_FLAGS=-fuse-ld=lld
T2_GCC_OPTIONS=
T2_CLANG_OPTIONS=-Wno-undefined-var-template -Wno-unknown-warning-option
T2_COMPILER_OPTIONS=$(T2_GCC_OPTIONS)
# if using clang set T2_COMPILER_OPTIONS to T2_CLANG_OPTIONS
T2_CFLAGS=-std=c++17 -Wall -fno-omit-frame-pointer -fmax-errors=5 -fno-rtti
T2_INCLUDE_EXTRA=
# .dll files that need to be copied from the compiler's bin
T2_SYSTEM_SO=
T2_SYSTEM_SO_LOCATION=


EXTRA_TARGETS=

# (add your target platform here)
ifeq ($(TARGET_OS),linux_arm64)
  #GCC- aarch64-linux-gnu-gcc
  #CLANG- clang --target=aarch64-linux-gnu --sysroot=/usr/aarch64-linux-gnu
  $(error aarch64 linux not yet supported)
endif

#######################################################################################
# Windows targets:
ifeq ($(TARGET_OS),win)
  PLATFORM_IS_SUPPORTED=TRUE
  
  TARGET=x86_64-w64-mingw32
  CC=$(TARGET)-gcc
  CXX=$(TARGET)-g++
  CXXFLAGS=-std=c++17
  AR=$(TARGET)-ar
  LD=$(TARGET)-ld
  RANLIB=$(TARGET)-ranlib
  CMAKE=$(TARGET)-cmake
  CONFIGURE=--build=$(CONFIGURE_BUILD) --host=$(TARGET)
  LIB=$(EXTLIB)/lib_win_x64/
  
  LUA_MAKE=mingw CC=$(CC)
  LUAJIT_MAKE=SHELL="sh -xv" HOST_CC="gcc -Wl,--out-implib,libluajit.dll.a" CROSS=$(TARGET)- TARGET_SYS=Windows TARGET_DLLNAME=libluajit.dll
  BGFX_MAKE=make -s mingw-gcc-debug64 mingw-gcc-release64 CC='$(CC)' CXX='$(CXX)' CXXFLAGS+='$(CXXFLAGS) -DM_PI=3.14159265358979323846264338327950288  -fuse-ld=lld'
  
  # T2 flags
  T2_SDL2_CONFILG_LIBS=-lmingw32 -lSDL2main -lSDL2
  T2_CXX_FLAGS= -Wa,-mbig-obj
  T2_TARGET_SPECIFIC_LINK_FLAGS= -Wl,--disable-dynamicbase -Wl,--disable-high-entropy-va $(LIB_LUA_LINK_FLAGS) -mwindows -lopengl32 -lws2_32 -liphlpapi -lpsapi -lintl 
  T2_LD_FLAGS= -fuse-ld=lld
  # if lld does not exist on on your build, symlink x86_64-w64-mingw32-lld as lld (or just blank out the above variable)
  T2_INCLUDE_EXTRA=$(EXTLIB)/include/bx_compat/mingw $(EXTLIB)/include/sdl-mingw/
  T2_SYSTEM_SO=libstdc++-6.dll libintl-8.dll libgcc_s_seh-1.dll libgomp-1.dll libwinpthread-1.dll libiconv-2.dll libssp-0.dll
  T2_SYSTEM_SO_LOCATION=/usr/$(TARGET)/bin/

  EXTRA_TARGETS=$(LIB)/sdl-mingw.bin
endif

#######################################################################################
# OSX Targets
# assumes we are cross compiling from linux to osx using osxcross (see osxcross on github, or scripts/updateOsxCross.sh for instructions for building osxcross)
# also assumes that we are using clang
IS_OSX=
ifeq ($(TARGET_OS),osx)
  IS_OSX=yes
else ifeq ($(TARGET_OS),osx_arm64)
  IS_OSX=yes
else ifeq ($(TARGET_OS),osx_arm64e)
  IS_OSX=yes
endif

ifeq ($(IS_OSX),yes)
  ifeq ($(TARGET_OS),osx)
    PLATFORM_IS_SUPPORTED=TRUE
  
    TARGET=x86_64-apple-darwin23
    BGFX_TARGET=osx-x64
    LIB=$(EXTLIB)/lib_osx_x64/
  else ifeq ($(TARGET_OS),osx_arm64)
    PLATFORM_IS_SUPPORTED=TRUE
  
    #todo: remove -lrt from assimp link, is it breaks
    TARGET=aarch64-apple-darwin23
    BGFX_TARGET=osx-arm64
    LIB=$(EXTLIB)/lib_osx_arm64/
  else ifeq ($(TARGET_OS),osx_arm64e)
    PLATFORM_IS_SUPPORTED=TRUE
  
    #todo: remove -lrt from assimp link, is it breaks
    TARGET=aarch64e-apple-darwin23
    BGFX_TARGET=osx-arm64e
    LIB=$(EXTLIB)/lib_osx_arm64e/
  endif
  
  CC=$(TARGET)-clang
  CXX=$(TARGET)-clang++
  T2_COMPILER_OPTIONS=$(T2_CLANG_OPTIONS)
  CXXFLAGS=-std=c++17
  AR=$(TARGET)-ar
  LD=$(TARGET)-ld
  RANLIB=$(TARGET)-ranlib
  CMAKE=$(TARGET)-cmake
  CONFIGURE=--build=$(CONFIGURE_BUILD) --host=$(TARGET)
  
  OSX_DEPLOYMENT_TARGET=13.5
  export MACOSX_DEPLOYMENT_TARGET=$(OSX_DEPLOYMENT_TARGET)
  OSX_PREFIX=/usr/osxcross/
  
  LUA_MAKE=posix CC="$(CC)" AR="$(AR) rcu" RANLIB=$(RANLIB)
  LUAJIT_MAKE=SHELL="sh -xv" HOST_CC=clang CROSS=$(TARGET)- CC=clang TARGET_SYS=Darwin
  BGFX_MAKE=OSXCROSS=$(OSX_PREFIX) GENIE="../bx/tools/bin/linux/genie --with-macos=$(OSX_DEPLOYMENT_TARGET)" make $(BGFX_TARGET) CC="$(CC)" CXX="$(CXX)" AR="$(AR)"
  
  # T2 flags
  T2_SDL2_CONFILG_LIBS=$(EXTERNAL_LINK_DIR_OSX)SDL2
  T2_CXX_FLAGS= -mmacosx-version-min=$(OSX_DEPLOYMENT_TARGET) -pagezero_size 10000 -image_base 100000000
  T2_TARGET_SPECIFIC_LINK_FLAGS= $(EXTERNAL_LINK_DIR_OSX)libintl.a -liconv -framework OpenGL -framework Cocoa -framework QuartzCore -Wl,"-weak_framework,Metal" -Wl,"-weak_framework,MetalKit" -framework IOKit
  T2_LD_FLAGS=
  T2_INCLUDE_EXTRA=$(EXTLIB)/include/sdl-osx/ $(EXTLIB)/include/intl-osx/
  
  EXTRA_TARGETS=$(LIB)/sdl-osx.bin $(LIB)/gettext.bin
endif

ifeq ($(PLATFORM_IS_SUPPORTED),FALSE)
  $(error Platform "$(TARGET_OS)" is not supported, edit platform.mk)
endif

# Update CFlags based on selected options
T2_CFLAGS+= $(T2_COMPILER_OPTIONS)
