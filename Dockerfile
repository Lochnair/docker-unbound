FROM alpine:3.4
MAINTAINER Nils Andreas Svee <me@lochnair.net>

LABEL Description="Unbound image based on Alpine 3.4"

RUN apk add \
    --no-cache \
    --update \
    curl \
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

CMD ["/usr/sbin/unbound", "-d", "-v", "-c", "/etc/unbound/unbound.conf"]
