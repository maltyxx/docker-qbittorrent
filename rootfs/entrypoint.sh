#!/bin/sh -e

# Default configuration file
if [ ! -f /qbittorrent/config/qBittorrent.conf ]; then
    cp /qbittorrent/default/qBittorrent.conf /qbittorrent/config/qBittorrent.conf
fi

# Setup user/group ids
CHANGE_ID=0

if [ ! -z "${QBITTORRENT_UID}" ]; then
    if [ ! "$(id -u qbittorrent)" -eq "${QBITTORRENT_UID}" ]; then
        # Change the UID
        usermod -o -u "${QBITTORRENT_UID}" qbittorrent
        CHANGE_ID=1
    fi
fi
if [ ! -z "${QBITTORRENT_GID}" ]; then
    if [ ! "$(id -g qbittorrent)" -eq "${QBITTORRENT_GID}" ]; then
        groupmod -o -g "${QBITTORRENT_GID}" qbittorrent
        CHANGE_ID=1
    fi
fi

if [ $CHANGE_ID -eq 1 ]; then
    chown -R -h qbittorrent:qbittorrent /home/qbittorrent /qbittorrent
fi

exec su-exec qbittorrent "$@"