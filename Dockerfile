FROM debian:13-slim

LABEL org.opencontainers.image.authors="info@paessler.com"
LABEL org.opencontainers.image.vendor="Paessler GmbH"
LABEL org.opencontainers.image.licenses="MIT"

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FB_RELEASE=bookworm

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
    apt-get update && apt-get full-upgrade \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates \
        python3-minimal \
        gosu \
        libcap2-bin \
    && apt-get clean

# Add Paessler's official package repository with current release specifications.
# If the current release is not present on Paessler's servers fallback to defined fallback release.
RUN \
    apt-get -qq update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        curl \
    && curl --fail https://packages.paessler.com/keys/paessler.asc > /usr/share/keyrings/paessler-archive-keyring.asc \
    && curl --fail https://packages.paessler.com/docs/apt-sources/$(. /etc/os-release && $VERSION_CODENAME).sources \
    || curl --fail https://packages.paessler.com/docs/apt-sources/${DEBIAN_FB_RELEASE}.sources > /etc/apt/sources.list.d/paessler.sources \
    && apt-get -y remove --purge curl \
    && apt-get clean

# install the latest multi-platform probe
RUN \
    apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        prtgmpprobe \
    && apt-get autoremove -y \
    && apt-get clean

# add entrypoint script
COPY --chown=root:root --chmod=0555 run-prtgmpprobe.sh /entrypoint.sh

# specify volumes:
# - /config : configuration directory for the prtgmpprobe, put your config.yml here.
# - /opt/paessler/share/scripts : scripts directory for the Script v2 sensor. Mount your scripts here.
VOLUME [ "/config", "/opt/paessler/share/scripts" ]

# set WORKDIR to a sane default
WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "service-run" ]
