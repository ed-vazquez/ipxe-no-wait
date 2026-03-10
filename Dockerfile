FROM alpine:3.21 AS source

RUN apk add --no-cache git
ARG IPXE_VERSION=v1.21.1
WORKDIR /ipxe
RUN git clone --depth 1 --branch ${IPXE_VERSION} https://github.com/ipxe/ipxe.git .

FROM ghcr.io/ipxe/ipxe-builder-x86_64 AS builder

COPY --from=source /ipxe /ipxe
WORKDIR /ipxe/src
COPY config/ config/local/

RUN make -j$(nproc) bin-x86_64-efi/snponly.efi bin/undionly.kpxe

FROM scratch
COPY --from=builder /ipxe/src/bin-x86_64-efi/snponly.efi /ipxe-snponly-x86_64.efi
COPY --from=builder /ipxe/src/bin/undionly.kpxe /undionly.kpxe
