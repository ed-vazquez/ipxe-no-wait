# ipxe-no-wait

Pre-built [iPXE](https://ipxe.org) binaries optimized for fast PXE boot on IPv4 networks. Eliminates unnecessary wait times in the standard iPXE boot sequence.

## What it does

A stock iPXE build includes several network timeouts that add up on simple IPv4 PXE environments:

| Optimization | Time saved | How |
|---|---|---|
| Disable IPv6 | ~6s | Skips the IPv6 configurator timeout during the "Configuring" phase |
| Skip ProxyDHCP wait | ~4s | Stops waiting for a secondary DHCP offer when all PXE options come from the main DHCP server |
| SNP-only EFI binary | varies | Uses only the boot NIC instead of enumerating all network interfaces |

Total boot time reduction is roughly **10 seconds** compared to stock iPXE.

## Build artifacts

| File | Format | Use case |
|---|---|---|
| `ipxe-snponly-x86_64.efi` | EFI | UEFI PXE boot (x86_64) |
| `undionly.kpxe` | BIOS | Legacy BIOS PXE boot via UNDI |

Download pre-built binaries from the [Releases](../../releases) page.

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

Binaries are written to `output/`.

To clean up:

```sh
make clean
```

## How it works

This repo does **not** fork or modify iPXE source code. It uses iPXE's built-in `config/local/` override mechanism to change compile-time defaults:

- `config/general.h` — disables `NET_PROTO_IPV6`
- `config/dhcp.h` — sets `DHCP_DISC_PROXY_TIMEOUT_SEC` and `DHCP_REQ_PROXY_TIMEOUT_SEC` to 0

The Dockerfile clones upstream iPXE at a pinned tag, copies the config overrides, and builds the binaries.

## Updating iPXE version

Edit the `IPXE_VERSION` build arg in the `Dockerfile`:

```dockerfile
ARG IPXE_VERSION=v1.21.1
```

Then tag a new release to trigger a build:

```sh
git tag v1.21.1
git push origin v1.21.1
```

## License

The build tooling in this repository is provided under the [MIT License](LICENSE). The iPXE binaries produced are subject to the [iPXE license](https://ipxe.org/licensing) (GPL).
