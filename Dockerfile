FROM ghcr.io/onedr0p/alpine:3.18.0@sha256:dd504f02473c176a0e68e4550ccaf6f6c0f14e9f64c08a59877f9c6153bf48a9
WORKDIR /

# iproute2 -> bridge
# bind-tools -> dig, bind
# dhclient -> get dynamic IP
# dnsmasq-dnssec -> DNS & DHCP server with DNSSEC support
# coreutils -> need REAL chown and chmod for dhclient (it uses reference option not supported in busybox)
# bash -> for scripting logic
# inotify-tools -> inotifyd for dnsmask resolv.conf reload circumvention
RUN apk add --no-cache coreutils dhclient dnsmasq-dnssec git inotify-tools iproute2 wireguard-tools

### Private Internet Access repository and scripts
ARG PIA_BRANCH=master
ARG PIA_REPO=https://github.com/pia-foss/manual-connections
ARG PIA_TAG=v2.0.0

RUN mkdir /src \
    && git clone --branch "${PIA_BRANCH}" --single-branch --depth 1 "${PIA_REPO}" /src/manual-connections \
    && cd src/manual-connections \
    && git fetch --all --tags \
    && git checkout tags/${PIA_TAG}

### Custom versions of "/src/manual-connections/run_setup.sh" and "/usr/bin/wg-quick"
#   Use 'echo > 1 /proc_w/sys/...' instead of 'sysctl'
RUN rm /src/manual-connections/run_setup.sh /usr/bin/wg-quick
COPY ./scripts/wg-quick /usr/bin/wg-quick
COPY ./scripts/run_setup.sh /src/manual-connections/run_setup.sh
RUN chmod +x /usr/bin/wg-quick /src/manual-connections/run_setup.sh

# Env vars that the PIA script accepts
ENV PIA_USER="" \
    PIA_PASS="" \
    DIP_TOKEN="" \
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
ENTRYPOINT ["tail", "-f", "/dev/null"]
# ENTRYPOINT ["./src/manual-connections/run_setup.sh"]
