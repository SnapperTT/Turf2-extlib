#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# install_sysroot_packages.sh <sysroot>
# You need dpkg installed on your host machine
# ----------------------------------------

SYSROOT=$1
shift

# Raspberry Pi OS repo
RPI_REPO="http://archive.raspberrypi.org/debian"
DIST="trixie"
ARCH="arm64"

# Temporary working dir
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Map to keep track of resolved packages
declare -A RESOLVED_DEPS

PKG_INDEX="$TMPDIR/Packages"

# ------------------------------
# Fetch Packages.gz
# ------------------------------
function fetch_packages_index() {
    echo "[*] Fetching package index for $ARCH..."
    curl -s "$RPI_REPO/dists/$DIST/main/binary-$ARCH/Packages.gz" | gzip -d > "$PKG_INDEX"
}

# ------------------------------
# List available packages
# ------------------------------
function list_packages() {
    awk -F': ' '/^Package:/ {print $2}' "$PKG_INDEX" | sort
}

# ------------------------------
# Resolve dependencies recursively
# ------------------------------
function resolve_deps() {
    local pkg=$1

    # Already resolved or installed in sysroot
    if [[ ${RESOLVED_DEPS[$pkg]+_} ]]; then
        return
    fi

    # Check if package is installed in sysroot
    local status_file="${SYSROOT}/var/lib/dpkg/status"
    if grep -q -E "^Package: ${pkg}$" "$status_file"; then
        echo "[+] Package $pkg already installed in sysroot"
        return
    fi

    # Mark as missing (needs to be resolved)
    RESOLVED_DEPS[$pkg]=1
    echo "[*] Package $pkg missing, will resolve"

    # Get package info from your index
    local info
    info=$(awk "/^Package: $pkg$/,/^$/" "$PKG_INDEX")
    if [[ -z "$info" ]]; then
        echo "[-] Package $pkg not found in index!"
        return
    fi

    # Extract dependencies
    local deps
    deps=$(echo "$info" | awk -F': ' '/^Depends:/ {print $2}' || true)
    if [[ -n "$deps" ]]; then
        IFS=',' read -ra dep_list <<< "$deps"
        for dep in "${dep_list[@]}"; do
            # Strip version info and alternatives
            dep=$(echo "$dep" | sed 's/([^)])//g' | awk '{print $1}' | cut -d '|' -f1)
            [[ -n "$dep" ]] && resolve_deps "$dep"
        done
    fi
}

function resolve_deps_old() {
    local pkg=$1

    if [[ ${RESOLVED_DEPS[$pkg]+_} ]]; then
        return
    fi

    RESOLVED_DEPS[$pkg]=1

    local info=$(awk "/^Package: $pkg$/,/^$/" "$PKG_INDEX")
    if [[ -z "$info" ]]; then
        echo "[-] Package $pkg not found!"
        return
    fi

    local deps=$(echo "$info" | awk -F': ' '/^Depends:/ {print $2}' || true)
    if [[ -n "$deps" ]]; then
        IFS=',' read -ra dep_list <<< "$deps"
        for dep in "${dep_list[@]}"; do
            dep=$(echo "$dep" | sed 's/([^)])//g' | awk '{print $1}' | cut -d '|' -f1)
            [[ -n "$dep" ]] && resolve_deps "$dep"
        done
    fi
}

# ------------------------------
# Install package into sysroot
# ------------------------------
function install_package() {
    local pkg=$1

    local url_path=$(awk "/^Package: $pkg$/,/^$/" "$PKG_INDEX" | awk -F': ' '/^Filename:/ {print $2}')
    if [[ -z "$url_path" ]]; then
        echo "[-] Cannot find .deb for $pkg"
        return
    fi

    local url="$RPI_REPO/$url_path"
    local deb_file="$TMPDIR/$(basename "$url_path")"

    echo "[*] Downloading $pkg..."
    curl -sSL -o "$deb_file" "$url"

    echo "[*] Installing $pkg into $SYSROOT..."
    dpkg-deb -x "$deb_file" "$SYSROOT/tmp/fakeroot"
    rsync -a --keep-dirlinks "$SYSROOT/tmp/fakeroot/" "$SYSROOT"
    #rm -rf "$SYSROOT/tmp/fakeroot"
}

# ------------------------------
# Install already-downloaded .deb manually
# ------------------------------
function install_manual() {
    for deb_file in "$@"; do
        if [[ ! -f "$deb_file" ]]; then
            echo "[-] File not found: $deb_file"
            continue
        fi
        echo "[*] Installing $(basename "$deb_file") into $SYSROOT..."
        dpkg-deb -x "$deb_file" "$SYSROOT/tmp/fakeroot"
        rsync -a --keep-dirlinks "$SYSROOT/tmp/fakeroot/" "$SYSROOT"
        rm -rf "$SYSROOT/tmp/fakeroot"
    done
    echo "[*] Done. Manual .deb files installed into $SYSROOT."
}

# ------------------------------
# Command line parsing
# ------------------------------
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <sysroot> [--list-packages | --resolve-deps pkg1 pkg2 ... | --install pkg1 pkg2 ... | --manual pkg1.deb pkg2.deb ...]"
    exit 1
fi

fetch_packages_index

case "$1" in
    --list-packages)
        list_packages
        ;;
    --resolve-deps)
        shift
        for pkg in "$@"; do
            resolve_deps "$pkg"
        done
        echo "[*] Dependency tree resolved:"
        for pkg in "${!RESOLVED_DEPS[@]}"; do
            echo "  $pkg"
        done
        ;;
    --install)
        shift
        # do not auto-resolve and install dependencies
        # sometimes installing dependencies over an existing sysroot can mess up the existing sysroot
        #for pkg in "$@"; do
        #    resolve_deps "$pkg"
        #done
        #echo "[*] Installing packages..."
        #for pkg in "${!RESOLVED_DEPS[@]}"; do
        echo "[*] Installing packages..."
        for pkg in "$@"; do
            install_package "$pkg"
        done
        echo "[*] Done. Packages installed into $SYSROOT."
        ;;
    --manual)
        shift
        install_manual "$@"
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
esac
