ARG IPXE_VERSION=v2.0.0

FROM alpine:3.21 AS source
ARG IPXE_VERSION
RUN apk add --no-cache git
WORKDIR /build
COPY config/ config/
COPY scripts/ scripts/
RUN ./scripts/clone.sh ${IPXE_VERSION} config ipxe

FROM ghcr.io/ipxe/ipxe-builder-x86_64 AS build-x86_64
COPY --from=source /build/ /build/
WORKDIR /build
RUN ./scripts/build.sh x86_64 ipxe output

FROM ghcr.io/ipxe/ipxe-builder-arm32 AS build-arm32
COPY --from=source /build/ /build/
WORKDIR /build
RUN ./scripts/build.sh arm32 ipxe output

FROM ghcr.io/ipxe/ipxe-builder-arm64 AS build-arm64
COPY --from=source /build/ /build/
WORKDIR /build
RUN ./scripts/build.sh arm64 ipxe output

FROM ghcr.io/ipxe/ipxe-builder-x86_64 AS package
COPY --from=source /build/ /build/
COPY --from=build-x86_64 /build/ipxe/src/bin/ /build/ipxe/src/bin/
COPY --from=build-x86_64 /build/ipxe/src/bin-x86_64-pcbios/ /build/ipxe/src/bin-x86_64-pcbios/
COPY --from=build-x86_64 /build/ipxe/src/bin-x86_64-efi/ /build/ipxe/src/bin-x86_64-efi/
COPY --from=build-arm32 /build/ipxe/src/bin-arm32-efi/ /build/ipxe/src/bin-arm32-efi/
COPY --from=build-arm64 /build/ipxe/src/bin-arm64-efi/ /build/ipxe/src/bin-arm64-efi/
WORKDIR /build
RUN ./scripts/package.sh ipxe output

FROM scratch
COPY --from=package /build/output/ /
