# docker_wireguard

[![build status](https://img.shields.io/github/actions/workflow/status/padhi-homelab/docker_wireguard/docker-release.yml?label=BUILD&branch=main&logo=github&logoWidth=24&style=flat-square)](https://github.com/padhi-homelab/docker_wireguard/actions/workflows/docker-release.yml)
[![testing size](https://img.shields.io/docker/image-size/padhihomelab/wireguard/testing?label=SIZE%20%5Btesting%5D&logo=docker&logoColor=skyblue&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/wireguard/tags)
[![latest size](https://img.shields.io/docker/image-size/padhihomelab/wireguard/latest?label=SIZE%20%5Blatest%5D&logo=docker&logoColor=skyblue&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/wireguard/tags)
  
[![latest version](https://img.shields.io/docker/v/padhihomelab/wireguard/latest?label=LATEST&logo=linux-containers&logoWidth=20&labelColor=darkmagenta&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/wireguard/tags)
[![image pulls](https://img.shields.io/docker/pulls/padhihomelab/wireguard?label=PULLS&logo=data:image/svg%2bxml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCAzMiAzMiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZyBmaWxsPSIjZmZmIj4KICAgIDxwYXRoIGQ9Ik0yMC41ODcsMTQuNjEzLDE4LDE3LjI0NlY5Ljk4QTEuOTc5LDEuOTc5LDAsMCwwLDE2LjAyLDhoLS4wNEExLjk3OSwxLjk3OSwwLDAsMCwxNCw5Ljk4djYuOTYzbC0uMjYtLjA0Mi0yLjI0OC0yLjIyN2EyLjA5MSwyLjA5MSwwLDAsMC0yLjY1Ny0uMjkzQTEuOTczLDEuOTczLDAsMCwwLDguNTgsMTcuNGw2LjA3NCw2LjAxNmEyLjAxNywyLjAxNywwLDAsMCwyLjgzMywwbDUuOTM0LTZhMS45NywxLjk3LDAsMCwwLDAtMi44MDZBMi4wMTYsMi4wMTYsMCwwLDAsMjAuNTg3LDE0LjYxM1oiLz4KICAgIDxwYXRoIGQ9Ik0xNiwwQTE2LDE2LDAsMSwwLDMyLDE2LDE2LDE2LDAsMCwwLDE2LDBabTAsMjhBMTIsMTIsMCwxLDEsMjgsMTYsMTIuMDEzLDEyLjAxMywwLDAsMSwxNiwyOFoiLz4KICA8L2c+Cjwvc3ZnPgo=&logoWidth=20&labelColor=teal&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/wireguard)

---

A multiarch [WireGuard] Docker image, based on [Alpine Linux].

|        386         |       amd64        |       arm/v6       |       arm/v7       |       arm64        |      ppc64le       |       riscv64      |       s390x        |
| :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |



## Usage

```
docker run --name wg_container
           --cap-add=NET_ADMIN \
           -e CONFIG_FILE_NAME=client.conf \
           -v /path/to/config:/config \
           -it padhihomelab/wireguard
```

Starts a container running an `wireguard` client with the provided client configuration.
<br>
To route traffic from other containers via this container,
use `--net=container:wg_container` with `docker run` when creating those containers:

```
docker run --net=container:wg_container <target_image>
```

### (Optional) SOCKS5 Proxy

This image also contains a [Dante] server to optionally start a SOCKS5 proxy
that external clients may connect to.


[Alpine Linux]: https://alpinelinux.org/
[Dante]:        https://www.inet.no/dante/
[WireGuard]:    https://www.wireguard.com/
