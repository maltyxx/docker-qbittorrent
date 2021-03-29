FROM alpine:3

ARG LIBTORRENT_VERSION=1.2.12
ARG QBITTORRENT_VERSION=4.3.4.1

# Install required packages
RUN apk add --no-cache \
        tzdata \
        su-exec \
        shadow \
        boost-system \
        boost-thread \
        ca-certificates \
        libressl \
        qt5-qtbase \
        python3

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
    curl -L -o /tmp/libtorrent-$LIBTORRENT_VERSION.tar.gz "https://github.com/arvidn/libtorrent/archive/v$LIBTORRENT_VERSION.tar.gz" && \
    tar -xzv -C /tmp -f /tmp/libtorrent-$LIBTORRENT_VERSION.tar.gz && \
    cd /tmp/libtorrent-$LIBTORRENT_VERSION && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib && \
    make && \
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
    curl -L -o /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz "https://github.com/qbittorrent/qBittorrent/archive/release-$QBITTORRENT_VERSION.tar.gz" && \
    tar -xzv -C /tmp -f /tmp/qBittorrent-$QBITTORRENT_VERSION.tgz && \
    cd /tmp/qBittorrent-release-$QBITTORRENT_VERSION && \
    # Compile
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --disable-gui --disable-stacktrace && \
    make && \
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
        /qbittorrent \
        /home/qbittorrent/.config/qBittorrent \
        /home/qbittorrent/.local/share/data/qBittorrent \
        /home/qbittorrent/downloads \
    && \
    ln -s /home/qbittorrent/.config/qBittorrent /qbittorrent/config && \
    ln -s /home/qbittorrent/.local/share/data/qBittorrent /qbittorrent/data && \
    ln -s /home/qbittorrent/downloads /qbittorrent/downloads && \
    chmod 750 -R /home/qbittorrent && \
    chown -R -h qbittorrent:qbittorrent \
        /qbittorrent \
        /home/qbittorrent

# Default configuration file.
ADD rootfs/ /

ENV HOME="/home/qbittorrent/"
ENV QBITTORRENT_UID=520
ENV QBITTORRENT_GID=520

EXPOSE 8080/tcp 6881

VOLUME ["/qbittorrent/config", "/qbittorrent/data", "/qbittorrent/downloads"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["qbittorrent-nox"]
