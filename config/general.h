/* ipxe-no-wait: local build overrides */

/* Disable IPv6 — eliminates ~6s timeout on IPv4-only networks during
   the "Configuring" phase where the IPv6 configurator waits */
#undef NET_PROTO_IPV6
