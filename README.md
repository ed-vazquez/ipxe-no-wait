# ipxe-no-wait

Pre-built [iPXE](https://ipxe.org) binaries optimized for fast PXE boot on IPv4 networks. Eliminates unnecessary wait times in the standard iPXE boot sequence.

Based on upstream [iPXE v2.0.0](https://github.com/ipxe/ipxe/releases/tag/v2.0.0).

## What it does

A stock iPXE build includes several network timeouts that add up on simple IPv4 PXE environments:

| Optimization | Time saved | How |
|---|---|---|
| Disable IPv6 | ~6s | Skips the IPv6 configurator timeout during the "Configuring" phase |
| Skip ProxyDHCP wait | ~4s | Stops waiting for a secondary DHCP offer when all PXE options come from the main DHCP server |
| SNP-only EFI binary | varies | Uses only the boot NIC instead of enumerating all network interfaces |

Total boot time reduction is roughly **10 seconds** compared to stock iPXE.

## Release artifacts

Release artifacts match the [upstream iPXE](https://github.com/ipxe/ipxe/releases) naming:

| File | Description |
|---|---|
| `ipxe-x86_64.iso` | Bootable ISO (x86_64 BIOS + EFI) |
| `ipxe-x86_64.usb` | Bootable USB image (x86_64 BIOS + EFI) |
| `ipxeboot.tar.gz` | Network boot server files for TFTP deployment |

The `ipxeboot.tar.gz` contains individual binaries organized by architecture:

```
ipxeboot/
├── arm32/
│   ├── ipxe.efi
│   ├── ipxe-legacy.efi
│   └── snponly.efi
├── arm64/
│   ├── ipxe.efi
│   ├── ipxe-legacy.efi
│   └── snponly.efi
├── i386/
│   ├── ipxe.pxe
│   ├── ipxe-legacy.pxe
│   └── undionly.kpxe
└── x86_64/
    ├── ipxe.efi
    ├── ipxe-legacy.efi
    ├── ipxe.pxe
    ├── ipxe-legacy.pxe
    ├── snponly.efi
    └── undionly.kpxe
```

Download from the [Releases](../../releases) page.

## When to use this

These builds are right for you if:

- Your network is IPv4-only
- Your DHCP server provides all PXE options (next-server, boot filename) directly — no separate ProxyDHCP server
- You want faster PXE boot for discovery, provisioning, or imaging workflows

If you rely on ProxyDHCP or IPv6, use stock iPXE instead.

## Building locally

Requires Docker.

```sh
make build
```

Artifacts are written to `output/`.

To clean up:

```sh
make clean
```

## How it works

This repo does **not** fork or modify iPXE source code. It uses iPXE's built-in `config/local/` override mechanism to change compile-time defaults:

- `config/general.h` — disables `NET_PROTO_IPV6`
- `config/dhcp.h` — sets `DHCP_DISC_PROXY_TIMEOUT_SEC` and `DHCP_REQ_PROXY_TIMEOUT_SEC` to 0

The Dockerfile clones upstream iPXE at a pinned tag, copies the config overrides into `config/local/`, and builds using iPXE's official builder images (`ghcr.io/ipxe/ipxe-builder-*`) with cross-compilers for each architecture.

## Updating iPXE version

Edit the `IPXE_VERSION` build arg in the `Dockerfile`:

```dockerfile
ARG IPXE_VERSION=v2.0.0
```

Then tag a new release to trigger a build:

```sh
git tag v2.0.0
git push origin v2.0.0
```

## License

The build tooling in this repository is provided under the [MIT License](LICENSE). The iPXE binaries produced are subject to the [iPXE license](https://ipxe.org/licensing) (GPL).
