#!/bin/sh
#
# Build iPXE binaries for a given architecture.
#
# Usage: build.sh <arch> <ipxe-src-dir> <output-dir>
#
# Supported architectures: x86_64, arm32, arm64
# Expects config/local/ to already be populated in the source tree.

set -eu

ARCH="${1:?Usage: build.sh <arch> <ipxe-src-dir> <output-dir>}"
SRCDIR="${2:?Usage: build.sh <arch> <ipxe-src-dir> <output-dir>}"
OUTDIR="${3:?Usage: build.sh <arch> <ipxe-src-dir> <output-dir>}"

MAKEDIR="${SRCDIR}/src"
MAKEFLAGS="-j$(nproc)"

mkdir -p "${OUTDIR}"

case "${ARCH}" in
    x86_64)
        echo "==> Building BIOS (i386)"
        make -C "${MAKEDIR}" ${MAKEFLAGS} \
            bin/ipxe.pxe \
            bin/ipxe-legacy.pxe \
            bin/undionly.kpxe \
            bin/ipxe.lkrn

        echo "==> Building BIOS (x86_64)"
        make -C "${MAKEDIR}" ${MAKEFLAGS} \
            bin-x86_64-pcbios/ipxe.pxe \
            bin-x86_64-pcbios/ipxe-legacy.pxe \
            bin-x86_64-pcbios/undionly.kpxe \
            bin-x86_64-pcbios/ipxe.lkrn

        echo "==> Building EFI (x86_64)"
        make -C "${MAKEDIR}" ${MAKEFLAGS} \
            bin-x86_64-efi/ipxe.efi \
            bin-x86_64-efi/ipxe-legacy.efi \
            bin-x86_64-efi/snponly.efi
        ;;

    arm32)
        echo "==> Building EFI (arm32)"
        make -C "${MAKEDIR}" ${MAKEFLAGS} \
            bin-arm32-efi/ipxe.efi \
            bin-arm32-efi/ipxe-legacy.efi \
            bin-arm32-efi/snponly.efi
        ;;

    arm64)
        echo "==> Building EFI (arm64)"
        make -C "${MAKEDIR}" ${MAKEFLAGS} \
            bin-arm64-efi/ipxe.efi \
            bin-arm64-efi/ipxe-legacy.efi \
            bin-arm64-efi/snponly.efi
        ;;

    *)
        echo "Unknown architecture: ${ARCH}" >&2
        exit 1
        ;;
esac

echo "==> Done building ${ARCH}"
