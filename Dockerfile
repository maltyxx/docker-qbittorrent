FROM alpine:3.9

ARG LIBTORRENT_VERSION=1.1.10
ARG QBITTORRENT_VERSION=4.1.7

# Install required packages
RUN apk add --no-cache \
        tzdata \
        su-exec \
        shadow \
        boost-system \
        boost-thread \
        ca-certificates \
        libressl \
        qt5-qtbase

# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Libtorrent
RUN set -x && \
    # Install build dependencies
    apk add --no-cache -t .build-deps \
        boost-dev \
        curl \
        cmake \
        g++ \
        make \
        openssl-dev \
    && \
    # Build lib rasterbar from source code (required by qBittorrent)
    # Until https://github.com/qbittorrent/qBittorrent/issues/6132 is fixed, need to use version 1.0.*
    curl -L -o /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz "https://github.com/arvidn/libtorrent/releases/download/libtorrent-$(echo $LIBTORRENT_VERSION|tr '.' '_')/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz" && \
    tar -xzv -C /tmp -f /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz && \
    cd /tmp/libtorrent-rasterbar-$LIBTORRENT_VERSION && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    # Clean-up
    cd / && \
    apk del --purge .build-deps && \
    rm -rf /tmp/*

RUN set -x && \
    # Install build dependencies
    apk add --no-cache -t .build-deps \
        boost-dev \
        curl \
        g++ \
        make \
        openssl-dev \
        qt5-qttools-dev \
    && \
    # Build qBittorrent from source code
    curl -L -o /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz https://github.com/qbittorrent/qBittorrent/archive/release-$QBITTORRENT_VERSION.tar.gz && \
    tar -xzv -C /tmp -f /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz && \
    cd /tmp/qBittorrent-release-$QBITTORRENT_VERSION && \
    # Compile
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --disable-gui --disable-stacktrace && \
    make -j$(nproc) && \
    make install && \
    # Clean-up
    cd / && \
    apk del --purge .build-deps && \
    rm -rf /tmp/* && \
    # Add non-root user
    addgroup -S qbittorrent && \
    adduser -S -D -s /sbin/nologin -G qbittorrent qbittorrent && \
    # Create symbolic links to simplify mounting
    mkdir -p \
        /home/qbittorrent/.config/qBittorrent \
        /home/qbittorrent/.local/share/data/qBittorrent \
        /home/qbittorrent/downloads \
    && \
    ln -s /home/qbittorrent/.config/qBittorrent /config && \
    ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents && \
    ln -s /home/qbittorrent/downloads /downloads && \
    chmod 750 -R /home/qbittorrent && \
    chown -R -h qbittorrent:qbittorrent \
        /home/qbittorrent \
        /config \
        /torrents \
        /downloads

# Default configuration file.
COPY root/ /

ENV HOME="/home/qbittorrent/"
ENV QBITTORRENT_UID=520
ENV QBITTORRENT_GID=520

EXPOSE 8080/tcp 6881

VOLUME ["/config", "/torrents", "/downloads"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["qbittorrent-nox"]
