FROM ghcr.io/onedr0p/ubuntu:jammy-20230522@sha256:5611f930d6f1fed0731748a889016b031d34d875c6771c6972d314f356c2a23f
WORKDIR /

RUN apt-get update \
    && apt-get install -y git wireguard-tools iproute2 iptables

### Private Internet Access repository and scripts
ARG PIA_BRANCH=master
ARG PIA_REPO=https://github.com/pia-foss/manual-connections
ARG PIA_TAG=v2.0.0

USER kah:kah

RUN git clone --branch "${PIA_BRANCH}" --single-branch --depth 1 "${PIA_REPO}" /app \
    && cd /app \
    && git fetch --all --tags \
    && git checkout tags/${PIA_TAG}

# Env vars that the PIA script accepts
ENV PIA_USER= \
    PIA_PASS= \
    DIP_TOKEN="no" \
    PIA_DNS=true \
    PIA_PF=false \
    # set to false maybe?
    PIA_CONNECT=true \
    PIA_CONF_PATH="" \
    MAX_LATENCY=200 \
    AUTOCONNECT=true \
    PREFERRED_REGION="" \
    VPN_PROTOCOL="wireguard" \
    DISABLE_IPV6=yes

USER root
WORKDIR /app
ENTRYPOINT ["./run_setup.sh"]
