#!/bin/bash

set -Eumo pipefail

DNS_ENTRY=$(grep -i "^DNS" /etc/wireguard/wg0.conf | cut -d'=' -f2)
if [ -n "$DNS_ENTRY" ]; then
    for dns_ip in $(echo "$DNS_ENTRY" | tr ',' ' '); do
        echo "nameserver $dns_ip" >> /etc/resolv.conf
    done
    sed -i '/^DNS/d' /etc/wireguard/wg0.conf
else
    echo "No DNS found in config file. Potential leak! Aborting ..."
    exit 1
fi

wg-quick up wg0

if [ "$ENABLE_SOCKS_PROXY" -eq 1 ]; then
    sockd
else
    exec sleep infinity
fi
