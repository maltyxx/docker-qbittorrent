FROM alpine:3.9

ARG LIBTORRENT_VERSION=1.1.10
ARG QBITTORRENT_VERSION=4.1.6

# Install required packages
RUN apk add --no-cache \
        boost-system \
        boost-thread \
        ca-certificates \
        dumb-init \
        libressl \
        qt5-qtbase

# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Libtorrent
RUN set -x \
    # Install build dependencies
    && apk add --no-cache -t .build-deps \
        boost-dev \
        curl \
        cmake \
        g++ \
        make \
        openssl-dev \
    # Build lib rasterbar from source code (required by qBittorrent)
    # Until https://github.com/qbittorrent/qBittorrent/issues/6132 is fixed, need to use version 1.0.*
    && curl -L -o /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz "https://github.com/arvidn/libtorrent/releases/download/libtorrent-$(echo $LIBTORRENT_VERSION|tr '.' '_')/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz" \
    && tar -xzv -C /tmp -f /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz \
    && cd /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
       # Clean-up
    && cd / \
    && apk del --purge .build-deps \
    && rm -rf /tmp/*

RUN set -x \
    # Install build dependencies
    && apk add --no-cache -t .build-deps \
        boost-dev \
        curl \
        g++ \
        make \
        openssl-dev \
        qt5-qttools-dev \
    # Build qBittorrent from source code
    && curl -L -o /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz https://github.com/qbittorrent/qBittorrent/archive/release-$QBITTORRENT_VERSION.tar.gz \
    && tar -xzv -C /tmp -f /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz \
    && cd /tmp/qBittorrent-release-$QBITTORRENT_VERSION \
    # Compile
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --disable-gui --disable-stacktrace \
    && make -j$(nproc) \
    && make install \
    # Clean-up
    && cd / \
    && apk del --purge .build-deps \
    && rm -rf /tmp/* \
    # Add non-root user
    && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    # Create symbolic links to simplify mounting
    && mkdir -p /home/qbittorrent/.config/qBittorrent \
    && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
    && mkdir /downloads \
    && chmod go+rw -R /home/qbittorrent /downloads \
    && ln -s /home/qbittorrent/.config/qBittorrent /config \
    && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \
    # Check it works
    && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent

USER qbittorrent

EXPOSE 8080 6881

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD ["qbittorrent-nox"]
