/* ipxe-no-wait: eliminate ProxyDHCP wait times */

/* Skip waiting for a ProxyDHCP offer after receiving a valid DHCPOFFER.
   Unnecessary when all PXE options are served by the main DHCP server. */
#undef DHCP_DISC_PROXY_TIMEOUT_SEC
#define DHCP_DISC_PROXY_TIMEOUT_SEC	0

/* Skip ProxyDHCP request phase timeout for the same reason. */
#undef DHCP_REQ_PROXY_TIMEOUT_SEC
#define DHCP_REQ_PROXY_TIMEOUT_SEC	0
