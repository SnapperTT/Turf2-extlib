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
EXTERNAL_LIBS=$(LIB_LUA_STATIC) libsnappy.a libbacktrace.a $(LIB_BGFX_STATIC)
#libozz_animation.a libozz_base.a
# External shared libraries
EXTERNAL_SO_LINUX=libassimp.so libBulletCollision_turf2.so libBulletDynamics_turf2.so libLinearMath_turf2.so libdeflate.so
EXTERNAL_SO_WIN=libassimp.dll libBulletCollision_turf2.dll libBulletDynamics_turf2.dll libLinearMath_turf2.dll libdeflate.dll
EXTERNAL_SO_WIN2=libstdc++-6.dll libintl-8.dll libgcc_s_seh-1.dll libgomp-1.dll libwinpthread-1.dll libiconv-2.dll libssp-0.dll SDL2.dll
EXTERNAL_SO_OSX=

ifeq ($(TARGET_OS),linux)
  EXTERNAL_SO=$(EXTERNAL_SO_LINUX)
else ifeq ($(TARGET_OS),win)
  EXTERNAL_SO=$(EXTERNAL_SO_WIN) $(EXTERNAL_SO_WIN2)
else ifeq ($(TARGET_OS),osx)
  EXTERNAL_SO=$(EXTERNAL_SO_OSX)
endif
EXTERNAL_SO:=$(EXTERNAL_SO) $(LIB_LUA_DYNAMIC)


# Linker flags
EXTERNAL_LINK_DIR=$(LIB)


# Link
LDFLAGS=$(T2_LD_FLAGS) $(CFLAGS_DR) $(LDFLAGS_DR) -fmax-errors=5 -L $(EXTERNAL_LINK_DIR) $(T2_SDL2_CONFILG_LIBS) $(addprefix $(EXTERNAL_LINK_DIR),$(EXTERNAL_LIBS)) -lassimp -lBulletCollision_turf2 -lBulletDynamics_turf2 -lLinearMath_turf2 $(T2_TARGET_SPECIFIC_LINK_FLAGS)
