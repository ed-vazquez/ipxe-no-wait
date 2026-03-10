FROM alpine:3.20 AS builder

RUN apk add --no-cache \
    build-base \
    git \
    nasm \
    xz-dev \
    perl \
    bash \
    coreutils

ARG IPXE_VERSION=v1.21.1
WORKDIR /ipxe
RUN git clone --depth 1 --branch ${IPXE_VERSION} https://github.com/ipxe/ipxe.git .

WORKDIR /ipxe/src
COPY config/ config/local/

RUN make -j$(nproc) bin-x86_64-efi/snponly.efi bin/undionly.kpxe

FROM scratch
COPY --from=builder /ipxe/src/bin-x86_64-efi/snponly.efi /ipxe-snponly-x86_64.efi
COPY --from=builder /ipxe/src/bin/undionly.kpxe /undionly.kpxe
