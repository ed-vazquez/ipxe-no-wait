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

RUN make -j$(nproc) CC=gcc-9 \
    bin/ipxe.pxe \
    bin/ipxe-legacy.pxe \
    bin/undionly.kpxe \
    bin/ipxe.lkrn \
    bin-x86_64-pcbios/ipxe.pxe \
    bin-x86_64-pcbios/ipxe-legacy.pxe \
    bin-x86_64-pcbios/undionly.kpxe \
    bin-x86_64-pcbios/ipxe.lkrn \
    bin-x86_64-efi/ipxe.efi \
    bin-x86_64-efi/ipxe-legacy.efi \
    bin-x86_64-efi/snponly.efi

RUN ./util/gensrvimg -o /ipxeboot.tar.gz \
    bin/ipxe.pxe \
    bin/ipxe-legacy.pxe \
    bin/undionly.kpxe \
    bin-x86_64-pcbios/ipxe.pxe \
    bin-x86_64-pcbios/ipxe-legacy.pxe \
    bin-x86_64-pcbios/undionly.kpxe \
    bin-x86_64-efi/ipxe.efi \
    bin-x86_64-efi/ipxe-legacy.efi \
    bin-x86_64-efi/snponly.efi

RUN ./util/genfsimg -o /ipxe.iso \
    bin-x86_64-pcbios/ipxe.lkrn \
    bin-x86_64-efi/ipxe.efi

RUN ./util/genfsimg -o /ipxe.usb \
    bin-x86_64-pcbios/ipxe.lkrn \
    bin-x86_64-efi/ipxe.efi

FROM scratch
COPY --from=builder /ipxe.iso /ipxe.iso
COPY --from=builder /ipxe.usb /ipxe.usb
COPY --from=builder /ipxeboot.tar.gz /ipxeboot.tar.gz
