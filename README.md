# Welcome to Docker Qbittorrent

The [qBittorrent](https://www.qbittorrent.org/)  project aims to provide an open-source software alternative to µTorrent.
Its particularity is to have a web UI to manage your torrents from your server or your RaspberryPi.

Additionally, qBittorrent runs and provides the same features on all major platforms (Linux, macOS, Windows, OS/2, FreeBSD).

qBittorrent is based on the Qt toolkit and  [libtorrent-rasterbar](http://www.libtorrent.org/)  library.

# Supported architecture

- arm32 (Raspberry PI v3 B)
- arm64 (Raspberry PI v3 B+)

# Download / Update

```bash
docker pull maltyxx/qbittorrent:latest
```

#  Usage

-   `/config`: qBittorrent configuration files
-   `/torrents`: Torrent files
-   `/downloads`: Download location

By default it runs as UID 520 and GID 520, but can run as any user/group.

It is probably a good idea to add  `--restart=always`  so the container restarts if it goes down.

You can change  `6081`  to some random port number (also change in the settings).

```bash
docker run \
-p 8080:8080/tcp \
-p 6881:6881 \
-v <volume_config>:/config \
-v <volume_torrent>:/torrents \
-v <volume_download>:/downloads \
maltyxx/qbittorrent:4.1.6-arm32
```

## Exemple for Raspberry PI V3 B

```bash
docker run \
-d \
--name qbittorent \
--restart=always \
--log-driver json-file --log-opt max-size=10m \
-p 8080:8080/tcp \
-p 6881:6881 \
-v qbittorrent_config:/config \
-v qbittorrent_torrent:/torrents \
-v qbittorrent_downloads:/downloads \
maltyxx/qbittorrent:4.1.6-arm32
```

## WebUI

Login on the interface [http://localhost:8080](http://localhost:8080/).

Change your credentials :
-   `user`: admin
-   `password`: adminadmin

## Image Variants

`maltyxx/qbittorrent:latest`

The last version

### x86_64

`maltyxx/qbittorrent:<version>`

amd64 version
 
### ARM

`maltyxx/qbittorrent:<version>-<arch>`

arm version
