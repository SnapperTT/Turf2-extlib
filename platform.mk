#######################################################################################
# Platform Settings:
# IF YOU WANT TO ADD YOUR OWN PLATFORM copy the the settings here and add to the "ifeq/endif" section below
#
CONFIGURE_BUILD=x86_64-pc-linux

#######################################################################################
# Common Settings:
CXXSTD=-std=c++20
LISTED_TARGETS=

#######################################################################################
# Default target (linux x86)
PLATFORM_IS_SUPPORTED=FALSE

ifeq ($(TARGET_OS),linux)
  PLATFORM_IS_SUPPORTED=TRUE
endif

LISTED_TARGETS+=linux 
TARGET=
CC=gcc
CXX=g++
CXXFLAGS=$(CXXSTD)
AR=ar
LD=ld
RANLIB=ranlib
CMAKE_TOOLCHAIN=
CMAKE=cmake
CONFIGURE=
LIB=$(EXTLIB)/lib_lin_x64/
SYSROOT=
#copy windows tools to all platforms for ease of modding 
TOOLS_CP=lua52.exe lua52.dll shadercRelease.exe texturevRelease.exe

LUA_MAKE=linux MYCFLAGS=-g
LUAJIT_MAKE=
BGFX_MAKE=make -s  $(MAKE_VERBOSE_STR) linux-gcc CC='$(CC)' CXX='$(CXX)' CXX_FLAGS='$(CXXFLAGS)' AR='$(AR)'

ifeq ($(TARGET_OS),linux)
  TOOLS_CP+= lua52 shadercRelease texturevRelease
endif

# T2 flags
T2_SDL2_CONFILG_LIBS=`pkg-config --libs sdl3`
T2_CXX_FLAGS=
T2_TARGET_SPECIFIC_LINK_FLAGS=-latomic -ldl -lGL -lX11 -static-libstdc++ -Wl,-R./ -Wl,-R./build/
T2_LD_FLAGS=-fuse-ld=lld
T2_SYSROOT_INCLUDES=
T2_GCC_OPTIONS=
T2_CLANG_OPTIONS=-Wno-undefined-var-template -Wno-unknown-warning-option
T2_COMPILER_OPTIONS=$(T2_GCC_OPTIONS)
# if using clang set T2_COMPILER_OPTIONS to T2_CLANG_OPTIONS
T2_CFLAGS=$(CXXSTD) -Wall -fno-omit-frame-pointer -fmax-errors=5 -fno-rtti
T2_INCLUDE_EXTRA=
# .dll files that need to be copied from the compiler's bin
T2_SYSTEM_SO=
T2_SYSTEM_SO_LOCATION=

EXTRA_TARGETS=


# (add your target platform here)
LISTED_TARGETS+=rpi_arm64 
ifeq ($(TARGET_OS),rpi_arm64)
  PLATFORM_IS_SUPPORTED=TRUE
  SYSROOT=$(EXTLIB)/sysroots/rpi_arm64/

  # You must manually specify the include paths, otherwise gcc will look in the host's include. The order of these do matter, put the c++ libs first, then the c libs
  SYSROOT_INCLUDES_C= -I$(SYSROOT)/usr/include -I$(SYSROOT)/usr/include/aarch64-linux-gnu -L$(SYSROOT)/usr/lib/aarch64-linux-gnu
  SYSROOT_INCLUDES_CXX= -I$(SYSROOT)/usr/include/c++/14 -I$(SYSROOT)/usr/include/aarch64-linux-gnu/c++/14 -I$(SYSROOT)/usr/include -I$(SYSROOT)/usr/include/aarch64-linux-gnu -L$(SYSROOT)/usr/lib/gcc/aarch64-linux-gnu/14/ -L$(SYSROOT)/usr/lib/aarch64-linux-gnu

  TARGET=aarch64-linux-gnu
  CC=$(TARGET)-gcc
  CXX=$(TARGET)-g++
  CXXFLAGS=$(CXXSTD) --sysroot=$(SYSROOT)
  AR=$(TARGET)-ar
  LD=$(TARGET)-ld 
  RANLIB=$(TARGET)-ranlib
  CMAKE=cmake
  CMAKE_TOOLCHAIN=-DCMAKE_TOOLCHAIN_FILE=$(EXTLIB)/sysroots/rpi_arm64_toolchain.cmake -DCMAKE_SYSROOT=$(SYSROOT) -DCMAKE_SYSROOT_INCLUDES_C='$(SYSROOT_INCLUDES_C)' -DCMAKE_SYSROOT_INCLUDES_CXX='$(SYSROOT_INCLUDES_CXX)'
  CONFIGURE=--build=$(CONFIGURE_BUILD) --host=$(TARGET) --with-sysroot=$(SYSROOT)
  LIB=$(EXTLIB)/lib_rpi_arm64/
  
  LUA_MAKE=posix CC="$(CC)" AR="$(AR) rcu" MYCFLAGS='-g --sysroot=$(SYSROOT) $(SYSROOT_INCLUDES_C)' RANLIB=$(RANLIB)
  LUAJIT_MAKE=SHELL="sh -xv" HOST_CC=gcc CROSS=$(TARGET)- TARGET_CFKAGS=' --sysroot=$(SYSROOT) $(SYSROOT_INCLUDES_C)'
  BGFX_GLES_VER=-DBGFX_CONFIG_RENDERER_OPENGLES=30
  BGFX_MAKE=make -s $(MAKE_VERBOSE_STR) rpi CC='$(CC)' CXX='$(CXX)' CPPFLAGS='$(CXXFLAGS) $(SYSROOT_INCLUDES_CXX) $(BGFX_GLES_VER)' AR='$(AR)'
  
  T2_CXX_FLAGS=$(BGFX_GLES_VER)
  T2_SYSROOT_INCLUDES= --sysroot=$(SYSROOT) $(SYSROOT_INCLUDES_CXX)
  RPIUSRLIB=$(SYSROOT)/usr/lib/aarch64-linux-gnu/
  #RPI_LIBS=$(addprefix $(RPIUSRLIB), libEGL.so.1 libGLESv2.so.2 libwayland-egl.so.1 libwayland-cursor.so.0 libwayland-client.so.0 libdecor-0.so.0 libxkbcommon.so.0 libdrm.so.2 libpipewire-0.3.so.0)
  RPI_LIBS=$(addprefix $(RPIUSRLIB), libEGL.so.1 libGLESv2.so.2)
  T2_TARGET_SPECIFIC_LINK_FLAGS= -latomic -lSDL3 $(RPI_LIBS) -lgbm -lX11 -ldl -Wl,-R./ -Wl,-R./build/
endif

#PRETTY_TARGET=\033[33m$(TARGET_OS)\033[0m

#######################################################################################
# Windows targets:
LISTED_TARGETS+=win 
ifeq ($(TARGET_OS),win)
  PLATFORM_IS_SUPPORTED=TRUE
  
  TARGET=x86_64-w64-mingw32
  CC=$(TARGET)-gcc
  CXX=$(TARGET)-g++
  CXXFLAGS=$(CXXSTD)
  AR=$(TARGET)-ar
  LD=$(TARGET)-ld
  RANLIB=$(TARGET)-ranlib
  CMAKE=$(TARGET)-cmake
  CONFIGURE=--build=$(CONFIGURE_BUILD) --host=$(TARGET)
  LIB=$(EXTLIB)/lib_win_x64/
  
  LUA_MAKE=mingw CC=$(CC)
  LUAJIT_MAKE=SHELL="sh -xv" HOST_CC="gcc -Wl,--out-implib,libluajit.dll.a" CROSS=$(TARGET)- TARGET_SYS=Windows TARGET_DLLNAME=libluajit.dll
  BGFX_MAKE=make -s  $(MAKE_VERBOSE_STR) mingw-gcc-debug64 mingw-gcc-release64 CC='$(CC)' CXX='$(CXX)' CXXFLAGS+='$(CXXFLAGS) -DM_PI=3.14159265358979323846264338327950288  -fuse-ld=lld'
  
  # T2 flags
  # -lSDL3main
  T2_SDL2_CONFILG_LIBS=-lmingw32 -lSDL3
  T2_CXX_FLAGS= -Wa,-mbig-obj
  T2_TARGET_SPECIFIC_LINK_FLAGS= -Wl,--disable-dynamicbase -Wl,--disable-high-entropy-va $(LIB_LUA_LINK_FLAGS) -mwindows -latomic -lopengl32 -lws2_32 -liphlpapi -lpsapi
  T2_LD_FLAGS= -fuse-ld=lld
  # if lld does not exist on on your build, symlink x86_64-w64-mingw32-lld as lld (or just blank out the above variable)
  T2_INCLUDE_EXTRA=$(EXTLIB)/include/bx_compat/mingw $(EXTLIB)/include/sdl-mingw/
  #libintl-8.dll libiconv-2.dll  <-- gnugettext. Has been removed
  T2_SYSTEM_SO=libstdc++-6.dll libgcc_s_seh-1.dll libgomp-1.dll libwinpthread-1.dll libssp-0.dll
  T2_SYSTEM_SO_LOCATION=/usr/$(TARGET)/bin/

  EXTRA_TARGETS=$(LIB)/sdl3-mingw.bin
  
  #PRETTY_TARGET=\033[34m$(TARGET_OS)\033[0m
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
LISTED_TARGETS+=osx 
LISTED_TARGETS+=osx_arm64 
LISTED_TARGETS+=osx_arm64e  

ifeq ($(IS_OSX),yes)
  ifeq ($(TARGET_OS),osx)
    PLATFORM_IS_SUPPORTED=TRUE
  
    TARGET=x86_64-apple-darwin23
    BGFX_TARGET=osx-x64
    LIB=$(EXTLIB)/lib_osx_x64/
  else ifeq ($(TARGET_OS),osx_arm64)
    PLATFORM_IS_SUPPORTED=TRUE
  
    #todo: remove -lrt from assimp link, is it breaks
    #aarch64 or arm64. Osxcross has simlinks between the two
    TARGET=arm64-apple-darwin23
    BGFX_TARGET=osx-arm64
    LIB=$(EXTLIB)/lib_osx_arm64/
  else ifeq ($(TARGET_OS),osx_arm64e)
    PLATFORM_IS_SUPPORTED=TRUE
  
    #todo: remove -lrt from assimp link, is it breaks
    TARGET=arm64e-apple-darwin23
    BGFX_TARGET=osx-arm64e
    LIB=$(EXTLIB)/lib_osx_arm64e/
  endif
  
  CC=$(TARGET)-clang
  CXX=$(TARGET)-clang++
  T2_COMPILER_OPTIONS=$(T2_CLANG_OPTIONS)
  CXXFLAGS=$(CXXSTD)
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
  BGFX_MAKE=OSXCROSS=$(OSX_PREFIX) GENIE="../bx/tools/bin/linux/genie --with-macos=$(OSX_DEPLOYMENT_TARGET)" make -s $(MAKE_VERBOSE_STR) $(BGFX_TARGET) CC="$(CC)" CXX="$(CXX)" AR="$(AR)"
  
  # T2 flags
  T2_SDL2_CONFILG_LIBS=-F$(EXTERNAL_LINK_DIR) -framework SDL3
  T2_CXX_FLAGS= -mmacosx-version-min=$(OSX_DEPLOYMENT_TARGET) -pagezero_size 10000 -image_base 100000000
  T2_TARGET_SPECIFIC_LINK_FLAGS= -liconv -framework OpenGL -framework Cocoa -framework QuartzCore -Wl,"-weak_framework,Metal" -Wl,"-weak_framework,MetalKit" -framework IOKit
  T2_LD_FLAGS=-Wl,-rpath,@executable_path/.
  T2_INCLUDE_EXTRA=$(EXTLIB)/include/sdl-osx/ $(EXTLIB)/include/intl-osx/
  
  EXTRA_TARGETS=$(LIB)/sdl3-osx.bin
  #PRETTY_TARGET=\033[32m$(TARGET_OS)\033[0m
endif

ifeq ($(PLATFORM_IS_SUPPORTED),FALSE)
  $(error Platform "$(TARGET_OS)" is not supported, edit platform.mk)
endif

# Update CFlags based on selected options
T2_CFLAGS+= $(T2_COMPILER_OPTIONS)
PRETTY_TARGET=$(TARGET_OS)
