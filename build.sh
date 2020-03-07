#!/bin/sh -e

QBITTORRENT_VERSION=4.2.1

exec docker buildx build --build-arg=QBITTORRENT_VERSION=$QBITTORRENT_VERSION --pull --platform linux/arm/v6,linux/arm/v7,linux/386,linux/arm64,linux/amd64 --tag maltyxx/qbittorrent:latest --tag maltyxx/qbittorrent:$QBITTORRENT_VERSION --push .
