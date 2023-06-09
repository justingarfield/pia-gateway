FROM ghcr.io/onedr0p/ubuntu:jammy-20230522@sha256:5611f930d6f1fed0731748a889016b031d34d875c6771c6972d314f356c2a23f
WORKDIR /

# iproute2 -> bridge
# bind-tools -> dig, bind
# dhclient -> get dynamic IP
# dnsmasq-dnssec -> DNS & DHCP server with DNSSEC support
# coreutils -> need REAL chown and chmod for dhclient (it uses reference option not supported in busybox)
# bash -> for scripting logic
# inotify-tools -> inotifyd for dnsmask resolv.conf reload circumvention
RUN apt-get update \
    && apt-get install -y git wireguard-tools iproute2 iptables

# RUN rm /usr/bin/wg-quick
# COPY --chmod=555 ./scripts/wg-quick /usr/bin/wg-quick

# RUN mkdir /app \
#    && chown kah:kah /app

### Private Internet Access repository and scripts
ARG PIA_BRANCH=master
ARG PIA_REPO=https://github.com/pia-foss/manual-connections
ARG PIA_TAG=v2.0.0

USER kah:kah

RUN git clone --branch "${PIA_BRANCH}" --single-branch --depth 1 "${PIA_REPO}" /app \
    && cd /app \
    && git fetch --all --tags \
    && git checkout tags/${PIA_TAG}

### Custom versions of "/src/manual-connections/run_setup.sh" and "/usr/bin/wg-quick"
#   Use 'echo > 1 /proc_w/sys/...' instead of 'sysctl'
# RUN rm /home/kah/manual-connections/run_setup.sh
# COPY --chown=kah:kah --chmod=555 ./scripts/run_setup.sh /home/kah/manual-connections/run_setup.sh

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

# WORKDIR /src
# ENTRYPOINT ["tail", "-f", "/dev/null"]

USER root
# RUN mkdir -p /dev/fd/63
# RUN touch /dev/fd/63
WORKDIR /app
ENTRYPOINT ["./run_setup.sh", "&&", "tail", "-f", "/dev/null"]
