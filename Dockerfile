FROM padhihomelab/alpine-base:3.23.3_0.19.0_0.3


ENV ENTRYPOINT_RUN_AS_ROOT=1

ENV CONFIG_FILE_NAME="client.conf"
ENV ENABLE_IPv6=0
ENV EXTRA_WG_FLAGS=""
ENV FORWARDED_PORTS=""

ENV ENABLE_SOCKS_PROXY=1
ENV PROXY_USERNAME="socks_user"
ENV PROXY_PASSWORD="socks_pass"


COPY start.sh    /usr/local/bin/start-wg
COPY sockd.conf  /etc/

COPY entrypoint-scripts \
     /etc/docker-entrypoint.d/99-extra-scripts


RUN chmod +x /usr/local/bin/start-wg \
             /etc/docker-entrypoint.d/99-extra-scripts/*.sh \
 && apk add --no-cache --update \
            bash \
            bind-tools \
            dante-server \
            ip6tables \
            wireguard-tools=1.0.20250521-r1

RUN sed -i 's/cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1//g' \
           /usr/bin/wg-quick


VOLUME [ "/config" ]

CMD start-wg


HEALTHCHECK --interval=15s --timeout=5s --start-period=15s \
        CMD ping -I wg0 -c 3 google.com || exit 1
