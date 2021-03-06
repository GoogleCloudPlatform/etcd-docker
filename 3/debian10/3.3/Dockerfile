FROM marketplace.gcr.io/google/debian10 as builder

# Update and install necessary packages

RUN set -ex; \
	apt-get update && \
	apt-get -y install \
	gnupg \
	wget \
	golang \
	govendor

# This is the release of Etcd to pull in.
ENV ETCD_VER=3.3.13
ENV ETCD_FILE=etcd-v${ETCD_VER}-linux-amd64.tar.gz

ENV GOPATH /usr/local
ENV ETCD_SHA256 2c2e2a9867c1c61697ea0d8c0f74c7e9f1b1cf53b75dff95ca3bc03feb19ea7e

# Download etcd version v3.3.13 and put binary files into /usr/local/bin
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

## Builded new "marketplace.gcr.io/google/debian10" container will contain only files copied from Builder image
FROM marketplace.gcr.io/google/debian10


ENV C2D_RELEASE=3.3.13

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
