FROM marketplace.gcr.io/google/c2d-debian11 as builder

# Update and install necessary packages

RUN set -ex; \
	apt-get update && \
	apt-get -y install \
	gnupg \
	wget \
	golang \
	govendor

# This is the release of Etcd to pull in.
ENV ETCD_VER=3.5.11
ENV ETCD_FILE=etcd-v${ETCD_VER}-linux-amd64.tar.gz

ENV GOPATH /usr/local
ENV ETCD_SHA256 e256885e753dc99001335e099d3c2eb8cf21a865a087ee4d7e3665752ae5929a

# Download etcd version v3.5.11 and put binary files into /usr/local/bin
RUN set -ex; \
    # Downloading source file
    wget -q https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/${ETCD_FILE} \
    # Check SHA256sum
    && echo "${ETCD_SHA256}" "${ETCD_FILE}" | sha256sum -c - \
    # Extracting and adding to binary directory
    && tar xzvf "${ETCD_FILE}" -C /tmp \
    && cp /tmp/etcd-v${ETCD_VER}-linux-amd64/etcd /usr/local/bin/ \
    && cp /tmp/etcd-v${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/

RUN set -eux \
    # Downloads source code
    && wget -q https://github.com/etcd-io/etcd/archive/v${ETCD_VER}.tar.gz \
    && mkdir -p "${GOPATH}/src/github.com/etcd-io/etcd" \
    && tar -xzf v${ETCD_VER}.tar.gz --strip-components=1 -C "${GOPATH}/src/github.com/etcd-io/etcd"

RUN set -eux \
    # Extracts licences
    && cd "${GOPATH}/src/github.com/etcd-io/etcd" \
    && govendor license +vendor > /NOTICES

# Download the release License
RUN wget -q https://raw.githubusercontent.com/etcd-io/etcd/v${ETCD_VER}/LICENSE -O /LICENSE

## Builded new "marketplace.gcr.io/google/c2d-debian11" container will contain only files copied from Builder image
FROM marketplace.gcr.io/google/c2d-debian11

RUN apt-get update \
    && apt-get -y install \
      gpgv \
      gzip \
      openssl \
      libc-bin \
      libc6 \
      libpcre2-8-0 \
      libssl1.1 \
      libgnutls30 \
      liblzma5 \
      libsystemd0 \
      libtirpc-common \
      libtirpc3 \
      libudev1 \
      zlib1g

ENV C2D_RELEASE=3.5.11

RUN mkdir /usr/share/etcd

COPY --from=builder /usr/local/bin/etcd /usr/local/bin/
COPY --from=builder /usr/local/bin/etcdctl /usr/local/bin/
COPY --from=builder /LICENSE /usr/share/etcd/LICENSE
COPY --from=builder /NOTICES /usr/share/etcd/NOTICES

ENV ETCD_DATA_DIR="/var/run/etcd/default.etcd"

COPY docker-entrypoint.sh /

RUN test ${C2D_RELEASE} = $(/usr/local/bin/etcd --version | grep "etcd Version:" | cut -d: -f2) \
         || { echo "Version check failed"; exit 1; }

EXPOSE 2379 2380

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["etcd"]
