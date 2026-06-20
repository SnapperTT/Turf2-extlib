# Purpose: Linking flags for osx
# Include stuff
INCLUDE_DIRS = $(EXTLIB)/include/ $(EXTLIB)/include/bullet/ $(LIB) $(T2_INCLUDE_EXTRA)
INCLUDE_SWITCHES=$(addprefix -I ,$(INCLUDE_DIRS))

# Handle lua & bgfx
LIB_LUA_STATIC=
LIB_LUA_DYNAMIC=
LIB_LUA_LINK_FLAGS=
LIB_BGFX_STATIC=
DEBUG_REL_STR=

ifeq ($(TARGET_MODE),release)
  DEBUG_REL_STR=" release"
  LIB_BGFX_STATIC=libbgfxRelease.a libbimgRelease.a libbimg_decodeRelease.a libbimg_encodeRelease.a libbxRelease.a
  # Use luajit
  ifeq ($(TARGET_OS),win)
    LIB_LUA_DYNAMIC=libluajit.dll
    LIB_LUA_LINK_FLAGS=libluajit.dll
  else
    LIB_LUA_STATIC=libluajit.a
  endif
else 
  LIB_BGFX_STATIC=libbgfxDebug.a libbimgDebug.a libbimg_decodeDebug.a libbimg_encodeDebug.a libbxDebug.a
  # Use std lua
  ifeq ($(TARGET_OS),win)
    LIB_LUA_DYNAMIC=lua52.dll
    LIB_LUA_LINK_FLAGS=-llua52
  else 
    LIB_LUA_STATIC=liblua.a
  endif
endif

# External staticly linked libraries
EXTERNAL_LIBS=libsnappy.a $(LIB_LUA_STATIC) libbacktrace.a $(LIB_BGFX_STATIC)
#libsnappy.a 
#libozz_animation.a libozz_base.a
# External shared libraries
EXTERNAL_SO_LINUX=libassimp.so libBulletCollision_turf2.so libBulletDynamics_turf2.so libLinearMath_turf2.so libdeflate.so
EXTERNAL_SO_WIN=libassimp-6.dll libBulletCollision_turf2.dll libBulletDynamics_turf2.dll libLinearMath_turf2.dll libdeflate.dll
EXTERNAL_SO_WIN2=SDL3.dll
EXTERNAL_SO_OSX=libassimp.dylib libBulletCollision_turf2.dylib libBulletDynamics_turf2.dylib libLinearMath_turf2.dylib libdeflate.dylib
EXTERNAL_SO_OSX_ARM64=libassimp.dylib libBulletCollision_turf2.dylib libBulletDynamics_turf2.dylib libLinearMath_turf2.dylib libdeflate.dylib
EXTERNAL_SO_OSX_ARM64E=libassimp.dylib libBulletCollision_turf2.dylib libBulletDynamics_turf2.dylib libLinearMath_turf2.dylib libdeflate.dylib
L_CURL=-lcurl -lws2_32 -lcrypt32 -lbcrypt -lz

ifeq ($(TARGET_OS),linux)
  EXTERNAL_SO=$(EXTERNAL_SO_LINUX)
  L_ASSIMP=-lassimp
  L_CURL=-lcurl
else ifeq ($(TARGET_OS), rpi_arm64)
  EXTERNAL_SO=$(EXTERNAL_SO_LINUX)
  L_ASSIMP=-lassimp
  L_CURL=-lcurl
else ifeq ($(TARGET_OS),win)
  EXTERNAL_SO=$(EXTERNAL_SO_WIN) $(EXTERNAL_SO_WIN2)
  L_ASSIMP=-lassimp-6
  L_CURL=-lcurl
else ifeq ($(TARGET_OS),osx)
  EXTERNAL_SO=$(EXTERNAL_SO_OSX)
  L_ASSIMP=-lassimp
  L_CURL=-lcurl
else ifeq ($(TARGET_OS),osx_arm64)
  EXTERNAL_SO=$(EXTERNAL_SO_OSX_ARM64)
  L_ASSIMP=-lassimp
  L_CURL=-lcurl
else ifeq ($(TARGET_OS),osx_arm64e)
  EXTERNAL_SO=$(EXTERNAL_SO_OSX_ARM64E)
  L_ASSIMP=-lassimp
  L_CURL=-lcurl
endif

EXTERNAL_SO:=$(EXTERNAL_SO) $(T2_SYSTEM_SO) $(LIB_LUA_DYNAMIC)


# Linker flags
EXTERNAL_LINK_DIR=$(LIB)

# Link
LDFLAGS=$(T2_LD_FLAGS) $(T2_SYSROOT_INCLUDES) $(CFLAGS_DR) $(LDFLAGS_DR) -fmax-errors=5 -L $(EXTERNAL_LINK_DIR) $(T2_SDL2_CONFILG_LIBS) $(addprefix $(EXTERNAL_LINK_DIR),$(EXTERNAL_LIBS)) $(L_ASSIMP) $(L_CURL) -ldeflate -lBulletCollision_turf2 -lBulletDynamics_turf2 -lLinearMath_turf2 $(T2_TARGET_SPECIFIC_LINK_FLAGS)
