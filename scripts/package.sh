#!/bin/sh
#
# Generate release artifacts from built iPXE binaries.
#
# Usage: package.sh <ipxe-src-dir> <output-dir>
#
# Expects all architectures to have been built already.

set -eu

SRCDIR="${1:?Usage: package.sh <ipxe-src-dir> <output-dir>}"
OUTDIR="${2:?Usage: package.sh <ipxe-src-dir> <output-dir>}"

MAKEDIR="${SRCDIR}/src"

mkdir -p "${OUTDIR}"

# Collect all server binaries that were built
SRVBINS=""
for f in \
    bin/ipxe.pxe \
    bin/ipxe-legacy.pxe \
    bin/undionly.kpxe \
    bin-x86_64-pcbios/ipxe.pxe \
    bin-x86_64-pcbios/ipxe-legacy.pxe \
    bin-x86_64-pcbios/undionly.kpxe \
    bin-x86_64-efi/ipxe.efi \
    bin-x86_64-efi/ipxe-legacy.efi \
    bin-x86_64-efi/snponly.efi \
    bin-arm32-efi/ipxe.efi \
    bin-arm32-efi/ipxe-legacy.efi \
    bin-arm32-efi/snponly.efi \
    bin-arm64-efi/ipxe.efi \
    bin-arm64-efi/ipxe-legacy.efi \
    bin-arm64-efi/snponly.efi
do
    if [ -f "${MAKEDIR}/${f}" ]; then
        SRVBINS="${SRVBINS} ${MAKEDIR}/${f}"
    fi
done

echo "==> Generating server tarball"
${MAKEDIR}/util/gensrvimg -o "${OUTDIR}/ipxeboot.tar.gz" ${SRVBINS}

# ISO and USB only if x86_64 was built
if [ -f "${MAKEDIR}/bin-x86_64-pcbios/ipxe.lkrn" ] && \
   [ -f "${MAKEDIR}/bin-x86_64-efi/ipxe.efi" ]; then

    FSARGS="${MAKEDIR}/bin-x86_64-pcbios/ipxe.lkrn ${MAKEDIR}/bin-x86_64-efi/ipxe.efi"

    # Add ARM EFI binaries to ISO/USB if available
    for arch in arm32 arm64; do
        if [ -f "${MAKEDIR}/bin-${arch}-efi/ipxe.efi" ]; then
            FSARGS="${FSARGS} ${MAKEDIR}/bin-${arch}-efi/ipxe.efi"
        fi
    done

    echo "==> Generating ISO"
    ${MAKEDIR}/util/genfsimg -o "${OUTDIR}/ipxe-x86_64.iso" ${FSARGS}

    echo "==> Generating USB image"
    ${MAKEDIR}/util/genfsimg -o "${OUTDIR}/ipxe-x86_64.usb" ${FSARGS}
fi

echo "==> Done. Artifacts in ${OUTDIR}/"
ls -lh "${OUTDIR}/"
