FROM alpine:edge
MAINTAINER Nils Andreas Svee <me@lochnair.net>

LABEL Description="Unbound image based on Alpine 3.4"

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.5/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

RUN apk add \
    --no-cache \
    --update \
    bash \
    curl \
    openssl \
    shadow \
    unbound

# Setup Unbound control
RUN unbound-control-setup

# Listen on all addresses
RUN sed -i "s/# interface: 2001:DB8::5/# interface: 2001:DB8::5\\n\\tinterface: 0.0.0.0\\n\\tinterface: ::0/g" /etc/unbound/unbound.conf

# Enable Unbound control
RUN sed -i "s/# control-enable: no/control-enable: yes/g" /etc/unbound/unbound.conf && \
    sed -i "s/# control-/control-/g" /etc/unbound/unbound.conf

# Install root hints
RUN curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache && \
    chown -R unbound:unbound /etc/unbound

VOLUME /etc/unbound

COPY root/ /

ENTRYPOINT ["/init"]
CMD ["/usr/sbin/unbound", "-d", "-v", "-c", "/etc/unbound/unbound.conf"]
