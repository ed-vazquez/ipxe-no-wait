#!/bin/sh
#
# Generate release notes matching upstream iPXE format.
#
# Usage: release-notes.sh <version> <repo-url> <output-file>

set -eu

VERSION="${1:?Usage: release-notes.sh <version> <repo-url> <output-file>}"
REPO_URL="${2:?Usage: release-notes.sh <version> <repo-url> <output-file>}"
OUTFILE="${3:?Usage: release-notes.sh <version> <repo-url> <output-file>}"

DOWNLOAD_URL="${REPO_URL}/releases/download/${VERSION}"

cat > "${OUTFILE}" <<EOF
Optimized [iPXE](https://ipxe.org) ${VERSION} build with reduced boot times for IPv4-only PXE environments.

Based on upstream [iPXE ${VERSION}](https://github.com/ipxe/ipxe/releases/tag/${VERSION}).

# Downloads

## Binaries

### ISO image

This ISO9660 image may be burned to a real CD-ROM, or be attached as virtual media.

- [\`ipxe-x86_64.iso\`](${DOWNLOAD_URL}/ipxe-x86_64.iso) (x86-64, BIOS/UEFI, no UEFI Secure Boot)

### USB image

This FAT filesystem image may be burned to a mass storage device such as a USB stick or SD card, or be attached as virtual media.

- [\`ipxe-x86_64.usb\`](${DOWNLOAD_URL}/ipxe-x86_64.usb) (x86-64, BIOS/UEFI, no UEFI Secure Boot)

### Network boot server files

This archive may be extracted to a TFTP or HTTP(S) server. Includes x86-64 (BIOS + UEFI), ARM32 (UEFI), and ARM64 (UEFI) binaries.

- [\`ipxeboot.tar.gz\`](${DOWNLOAD_URL}/ipxeboot.tar.gz)

## Source code

- [\`ipxe-${VERSION#v}.tar.gz\`](https://github.com/ipxe/ipxe/archive/${VERSION}.tar.gz) (upstream iPXE source)

## Optimizations

These builds apply the following compile-time overrides via iPXE's \`config/local/\` mechanism:

- **Disable IPv6** (\`#undef NET_PROTO_IPV6\`) — eliminates ~6s timeout on IPv4-only networks.
- **Skip ProxyDHCP wait** (\`DHCP_DISC_PROXY_TIMEOUT_SEC=0\`, \`DHCP_REQ_PROXY_TIMEOUT_SEC=0\`) — eliminates ~4s wait when all PXE options come from the main DHCP server.
- **SNP-only EFI binary** — uses only the boot NIC instead of enumerating all network interfaces.

Total boot time reduction is roughly **10 seconds** compared to stock iPXE.
EOF

echo "==> Release notes written to ${OUTFILE}"
