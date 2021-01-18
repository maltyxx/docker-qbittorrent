#!/bin/sh -e

QBITTORRENT_VERSION=4.3.2

exec docker buildx build --build-arg=NPROC=1 --build-arg=QBITTORRENT_VERSION=$QBITTORRENT_VERSION --pull --platform linux/arm/v7,linux/386,linux/arm64,linux/amd64 --tag maltyxx/qbittorrent:latest --tag maltyxx/qbittorrent:$QBITTORRENT_VERSION --push .
