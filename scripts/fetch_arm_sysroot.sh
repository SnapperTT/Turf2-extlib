#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage:
  $0 <option> [output_dir]

Options:
  1     Auto-download Raspberry Pi OS Lite 64-bit
  2     Auto-download Debian ARM64 (stable)
  3     Auto-download Ubuntu Server ARM64 (latest LTS)
  4     Auto-download Alpine Linux ARM64 (minirootfs)
  5     Auto-download Arch Linux ARM (aarch64 rootfs)
  6     Auto-download Linaro ARM64 rootfs
  <img> Use a local Raspberry Pi OS .img file

Example:
  $0 1 my_sysroot
  $0 debian.img custom_sysroot
EOF
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

OPT="$1"
shift
SYSROOT_DIR="$(pwd)/rpi5_sysroot"
if [[ $# -ge 1 ]]; then
    SYSROOT_DIR="$(realpath "$1")"
fi

TMPDIR=$(mktemp -d)
IMG=""
TARBALL=""

# --- Select option ---
case "$OPT" in
    1)
        echo "[*] Downloading Raspberry Pi OS Lite 64-bit..."
        URL="https://downloads.raspberrypi.com/raspios_lite_arm64_latest"
        wget -O "$TMPDIR/pi.img.xz" "$URL"
        xz -d "$TMPDIR/pi.img.xz"
        IMG="$TMPDIR/pi.img"
        ;;
    2)
        echo "[*] Downloading Debian ARM64 (stable rootfs)..."
        URL="https://cdimage.debian.org/cdimage/ports/latest/arm64/rootfs/debian-arm64-rootfs.tar.xz"
        wget -O "$TMPDIR/debian-rootfs.tar.xz" "$URL"
        TARBALL="$TMPDIR/debian-rootfs.tar.xz"
        ;;
    3)
        echo "[*] Downloading Ubuntu Server ARM64 (latest LTS)..."
        URL="https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.1-preinstalled-server-arm64+raspi.img.xz"
        wget -O "$TMPDIR/ubuntu.img.xz" "$URL"
        xz -d "$TMPDIR/ubuntu.img.xz"
        IMG="$TMPDIR/ubuntu.img"
        ;;
    4)
        echo "[*] Downloading Alpine Linux ARM64 minirootfs..."
        URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-latest-aarch64.tar.gz"
        wget -O "$TMPDIR/alpine.tar.gz" "$URL"
        TARBALL="$TMPDIR/alpine.tar.gz"
        ;;
    5)
        echo "[*] Downloading Arch Linux ARM aarch64 rootfs..."
        URL="http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
        wget -O "$TMPDIR/arch.tar.gz" "$URL"
        TARBALL="$TMPDIR/arch.tar.gz"
        ;;
    6)
        echo "[*] Downloading Linaro ARM64 rootfs..."
        URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/rootfs.tar.xz"
        wget -O "$TMPDIR/linaro-rootfs.tar.xz" "$URL"
        TARBALL="$TMPDIR/linaro-rootfs.tar.xz"
        ;;
    *)
        if [[ -f "$OPT" ]]; then
            IMG="$(realpath "$OPT")"
        else
            echo "Error: invalid option or file not found: $OPT"
            usage
        fi
        ;;
esac

mkdir -p "$SYSROOT_DIR"

# --- Extract from tarball ---
if [[ -n "$TARBALL" ]]; then
    echo "[*] Extracting tarball into $SYSROOT_DIR"
    sudo tar -xpf "$TARBALL" -C "$SYSROOT_DIR"
fi

# --- Extract from raw image ---
if [[ -n "$IMG" ]]; then
    echo "[*] Extracting sysroot from image: $IMG"
    SECTOR_SIZE=512
    ROOTFS_START=$(fdisk -l "$IMG" | awk '/Linux/ {print $2; exit}')
    if [[ -z "$ROOTFS_START" ]]; then
        echo "Error: could not find rootfs partition in $IMG"
        exit 1
    fi
    OFFSET=$((ROOTFS_START * SECTOR_SIZE))
    echo "[*] Rootfs starts at sector $ROOTFS_START (offset=$OFFSET)"
    MNT_DIR="$(mktemp -d)"
    sudo mount -o loop,offset=$OFFSET "$IMG" "$MNT_DIR"
    rsync -aHAX --delete --info=progress2 \
        --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' \
        "$MNT_DIR"/ "$SYSROOT_DIR"/
    sudo umount "$MNT_DIR"
    rmdir "$MNT_DIR"
fi

# --- Fix symlinks ---
echo "[*] Fixing absolute symlinks..."
find "$SYSROOT_DIR" -xtype l | while read -r link; do
    target=$(readlink "$link")
    if [[ "$target" = /* ]]; then
        rel_target=$(realpath --relative-to="$(dirname "$link")" "$SYSROOT_DIR$target" || true)
        if [[ -n "$rel_target" ]]; then
            ln -snf "$rel_target" "$link"
            echo "  fixed $link -> $rel_target"
        fi
    fi
done

echo "[*] Done. Sysroot available at: $SYSROOT_DIR"

