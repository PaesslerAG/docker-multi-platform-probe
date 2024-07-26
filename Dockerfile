FROM debian:11-slim

LABEL org.opencontainers.image.authors="info@paessler.com"
LABEL org.opencontainers.image.vendor="Paessler GmbH"
LABEL org.opencontainers.image.licenses="MIT"

ARG DEBIAN_FRONTEND=noninteractive

# enforce image to be up to date
RUN \
    apt-get update \
    && apt-get -y upgrade \
    && apt-get clean

# install necessary prerequisites
#
# needed additional packages:
# - ca-certificates (for TLS certificate validation and curl)
# - python3-minimal (for Script v2 sensor)
# - gosu            (to drop to unprivileged user)
# - libcap2-bin     (for setcap command)
#
RUN \
    apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates \
        python3-minimal \
        gosu \
        libcap2-bin \
    && apt-get clean

# add paessler's official package repository
RUN \
    apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        curl \
    && curl --fail --silent https://packages.paessler.com/keys/paessler.asc > /usr/share/keyrings/paessler-archive-keyring.asc \
    && curl --fail --silent https://packages.paessler.com/docs/apt-sources/$(. /etc/os-release && echo $VERSION_CODENAME).sources > /etc/apt/sources.list.d/paessler.sources \
    && apt-get -y remove --purge curl \
    && apt-get clean

# install the latest multi-platform probe
RUN \
    apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        prtgmpprobe \
    && apt-get clean

# add entrypoint script
COPY --chown=root:root --chmod=0555 run-prtgmpprobe.sh /run-prtgmpprobe.sh

# specify volumes:
# - /config : configuration directory for the prtgmpprobe, put your config.yml here.
# - /opt/paessler/share/scripts : scripts directory for the Script v2 sensor. Mount your scripts here.
VOLUME [ "/config", "/opt/paessler/share/scripts" ]

# set WORKDIR to a sane default
WORKDIR /

ENTRYPOINT [ "/run-prtgmpprobe.sh", "service-run" ]
