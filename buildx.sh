#!/bin/sh -e

QBITTORRENT_VERSION=4.3.3

exec docker buildx build --build-arg=NPROC=2 --build-arg=QBITTORRENT_VERSION=$QBITTORRENT_VERSION --pull --platform linux/arm64,linux/amd64 --tag maltyxx/qbittorrent:latest --tag maltyxx/qbittorrent:$QBITTORRENT_VERSION --push .
exec docker scan maltyxx/qbittorrent:$QBITTORRENT_VERSION