# Welcome to Docker Qbittorrent

The [qBittorrent](https://www.qbittorrent.org/) project aims to provide an open-source software alternative to µTorrent.
Its particularity is to have a web UI to manage your torrents from your server or your RaspberryPi.

Additionally, qBittorrent runs and provides the same features on all major platforms (Linux, macOS, Windows, OS/2, FreeBSD).

qBittorrent is based on the Qt toolkit and  [libtorrent-rasterbar](http://www.libtorrent.org/)  library.

# Supported multi architectures

- amd64
- arm64

# Download / Update

```bash
docker pull maltyxx/qbittorrent:latest
```

#  Usage

-   `/qbittorrent/config`: qBittorrent configuration files
-   `/qbittorrent/data`: qBittorrent database, logs, GeoIP, RSS...
-   `/qbittorrent/downloads`: Download location

By default it runs as UID 520 and GID 520, but can run as any user/group.

It is probably a good idea to add  `--restart=always`  so the container restarts if it goes down.

You can change  `6081`  to some random port number (also change in the settings).

```bash
docker run \
-p 8080:8080/tcp \
-p 6881:6881 \
-v <volume_config>:/qbittorrent/config \
-v <volume_data>:/qbittorrent/data \
-v <volume_download>:/qbittorrent/downloads \
maltyxx/qbittorrent:latest
```

## Exemple for a Raspberry 4 B

```bash
docker run \
-d \
--name qbittorent \
--restart=always \
--log-driver json-file --log-opt max-size=10m \
-p 8080:8080/tcp \
-p 6881:6881 \
-v qbittorrent-config:/qbittorrent/config \
-v qbittorrent-data:/qbittorrent/data \
-v qbittorrent-downloads:/qbittorrent/downloads \
-e TZ=Europe/Paris \
-e QBITTORRENT_UID=520 \
-e QBITTORRENT_GID=520 \
maltyxx/qbittorrent:latest
```

## WebUI

Login on the interface [http://localhost:8080](http://localhost:8080/).

Change your credentials :
-   `user`: admin
-   `password`: adminadmin

