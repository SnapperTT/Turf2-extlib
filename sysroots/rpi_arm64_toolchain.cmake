# rpi_aarch64_toolchain.cmake
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=$(EXTLIB)/rpi_arm64_toolchain.cmake -DCMAKE_SYSROOT=$(EXTLIB)/sysroots/rpi_arm64

# Target system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Cross compilers
set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Assemblers
set(CMAKE_ASM_COMPILER aarch64-linux-gnu-gcc)

# Archiving and linking tools
set(CMAKE_AR      aarch64-linux-gnu-ar)
set(CMAKE_RANLIB  aarch64-linux-gnu-ranlib)
set(CMAKE_NM      aarch64-linux-gnu-nm)
set(CMAKE_STRIP   aarch64-linux-gnu-strip)
set(CMAKE_OBJCOPY aarch64-linux-gnu-objcopy)
set(CMAKE_OBJDUMP aarch64-linux-gnu-objdump)

# --------------------------
# Sysroot configuration
# --------------------------
if(NOT DEFINED CMAKE_SYSROOT)
    message(FATAL_ERROR "Please pass -DCMAKE_SYSROOT=<path-to-sysroot>")
endif()

set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})

# Instruct compiler/linker where to find dynamic loader and libraries
set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--dynamic-linker=/lib/ld-linux-aarch64.so.1 \
     -L${CMAKE_SYSROOT}/lib/aarch64-linux-gnu \
     -L${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu"
)

# Search rules
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)  # Programs run on host
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)   # Libraries from sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)   # Headers from sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)   # Packages from sysroot


# Headers from sysroot
set(CMAKE_C_FLAGS "--sysroot=${CMAKE_SYSROOT}  ${CMAKE_SYSROOT_INCLUDES_C} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "--sysroot=${CMAKE_SYSROOT} ${CMAKE_SYSROOT_INCLUDES_CXX} ${CMAKE_CXX_FLAGS}")

#include_directories(SYSTEM ${CMAKE_SYSROOT}/usr/include)

# Optional: prevent CMake from appending host paths automatically
    
# pkgconfig
find_program(PKG_CONFIG_EXECUTABLE pkg-config)
if(NOT PKG_CONFIG_EXECUTABLE)
    message(FATAL_ERROR "pkg-config not found on host")
endif()

# Tell pkg-config to search inside sysroot
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")
set(ENV{PKG_CONFIG_PATH} "${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")

