#!/bin/sh
#
# Clone iPXE source and apply config overrides.
#
# Usage: clone.sh <ipxe-version> <config-dir> <dest-dir>
#
# Uses git if available, otherwise downloads a tarball.

set -eu

IPXE_VERSION="${1:?Usage: clone.sh <ipxe-version> <config-dir> <dest-dir>}"
CONFIG_DIR="${2:?Usage: clone.sh <ipxe-version> <config-dir> <dest-dir>}"
DEST_DIR="${3:?Usage: clone.sh <ipxe-version> <config-dir> <dest-dir>}"

if command -v git >/dev/null 2>&1; then
    echo "==> Cloning iPXE ${IPXE_VERSION}"
    git clone --depth 1 --branch "${IPXE_VERSION}" \
        https://github.com/ipxe/ipxe.git "${DEST_DIR}"
else
    echo "==> Downloading iPXE ${IPXE_VERSION} (git not available)"
    TARBALL_VERSION="${IPXE_VERSION#v}"
    curl -sL "https://github.com/ipxe/ipxe/archive/refs/tags/${IPXE_VERSION}.tar.gz" \
        | tar xz
    mv "ipxe-${TARBALL_VERSION}" "${DEST_DIR}"
fi

echo "==> Applying config overrides"
cp -r "${CONFIG_DIR}/"* "${DEST_DIR}/src/config/local/"

echo "==> Source ready at ${DEST_DIR}"
