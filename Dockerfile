FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-9 \
    libc6-dev \
    make \
    ca-certificates \
    git \
    liblzma-dev \
    isolinux \
    mtools \
    genisoimage \
    && rm -rf /var/lib/apt/lists/*

ARG IPXE_VERSION=v1.21.1
WORKDIR /ipxe
RUN git clone --depth 1 --branch ${IPXE_VERSION} https://github.com/ipxe/ipxe.git .

WORKDIR /ipxe/src
COPY config/ config/local/

RUN make -j$(nproc) bin-x86_64-efi/snponly.efi bin/undionly.kpxe CC=gcc-9

FROM scratch
COPY --from=builder /ipxe/src/bin-x86_64-efi/snponly.efi /ipxe-snponly-x86_64.efi
COPY --from=builder /ipxe/src/bin/undionly.kpxe /undionly.kpxe
