# aarch64-toolchain.cmake
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=(extlib)/rpi_arm64_toolchain.cmake -DCMAKE_SYSROOT=(extlib)/sysroots/rpi_arm64

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Set the compilers
set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Tell CMake where the sysroot is (passed in or default)
if(NOT CMAKE_SYSROOT)
    set(CMAKE_SYSROOT "sysroots/rpi_arm64")
endif()

# Compiler flags
set(CMAKE_C_FLAGS   "--sysroot=${CMAKE_SYSROOT} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "--sysroot=${CMAKE_SYSROOT} ${CMAKE_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "--sysroot=${CMAKE_SYSROOT} ${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "--sysroot=${CMAKE_SYSROOT} ${CMAKE_SHARED_LINKER_FLAGS}")

# pkg-config integration (if needed)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})
set(ENV{PKG_CONFIG_PATH} "${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")

# Optional: where to find includes/libraries
set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})

# Search inside sysroot first, then fall back
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
