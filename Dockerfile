FROM alpine:3.4
MAINTAINER Nils Andreas Svee <me@lochnair.net>

LABEL Description="Unbound image based on Alpine 3.4"

ENV VERSION 1.6.0

# Install build and runtime dependencies
RUN apk add \
    --no-cache \
    --update \
    build-base \
    curl \
    dnssec-root \
    expat \
    expat-dev \
    libevent \
    libevent-dev \
    linux-headers \
    openssl \
    openssl-dev \
    tar

# Download and compile Unbound
WORKDIR /usr/local/src/
RUN curl -O http://unbound.net/downloads/unbound-${VERSION}.tar.gz && \
    tar xf unbound-${VERSION}.tar.gz && \
    cd unbound-${VERSION} && \
    ./configure --help && \
    ./configure --prefix=/usr \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --with-username=unbound \
		--with-rootkey-file=/usr/share/dnssec-root/trusted-key.key \
                --with-libevent \
                --with-pthreads \
                --disable-static \
                --disable-rpath \
                --with-ssl \
                --without-pythonmodule && \
    # do not link to libpython
    sed -e '/^LIBS=/s/-lpython.*[[:space:]]/ /' -i Makefile && \
    make && \
    make install && \
    cd .. && \
    rm -R unbound-${VERSION} && \
    rm unbound-${VERSION}.tar.gz

# Create Unbound user
RUN addgroup -S unbound && \
    adduser -S -g unbound unbound

WORKDIR /root

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

# Remove build dependencies
RUN apk del \
    --no-cache \
    build-base \
    curl \
    expat-dev \
    libevent-dev \
    linux-headers \
    openssl-dev \
    tar

CMD ["/usr/sbin/unbound", "-d", "-v", "-c", "/etc/unbound/unbound.conf"]
