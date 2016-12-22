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

# Install root hints
RUN curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache && \
    chown -R unbound:unbound /etc/unbound

COPY root/ /

VOLUME /etc/unbound

ENTRYPOINT ["/init"]
CMD ["/usr/sbin/unbound", "-d", "-v", "-c", "/etc/unbound/unbound.conf"]
