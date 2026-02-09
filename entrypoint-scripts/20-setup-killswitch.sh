#!/bin/bash

set -Eumo pipefail

cd /etc/wireguard

echo "Creating WG kill switch and local routes..."

echo "Allowing established and related connections."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
[ "$ENABLE_IPv6" -eq 1 ] && ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "Allowing loopback connections."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
if [ "$ENABLE_IPv6" -eq 1 ] ; then
    ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -A OUTPUT -o lo -j ACCEPT
fi

echo "Allowing Docker network connections."
local_subnet_4=$(ip -4 r | grep -v 'default via' | grep eth0 | tail -n 1 | awk '{ print $1 }')
iptables -A INPUT -s $local_subnet_4 -j ACCEPT
iptables -A OUTPUT -d $local_subnet_4 -j ACCEPT
if [ "$ENABLE_IPv6" -eq 1 ]; then
    local_subnet_6=$(ip -6 r | grep -v 'default via' | grep eth0 | tail -n 1 | awk '{ print $1 }')
    ip6tables -A INPUT -s $local_subnet_6 -j ACCEPT
    ip6tables -A OUTPUT -d $local_subnet_6 -j ACCEPT
fi

echo "Allowing remote endpoint in configuration file."
endpoint=$(grep -i "^Endpoint" /etc/wireguard/wg0.conf | cut -d'=' -f2 | tr -d ' ')
domain=$(echo $endpoint | rev | cut -d: -f2- | rev)
port=$(echo $endpoint | rev | cut -d: -f1 | rev)
proto=udp
if ip route get $domain > /dev/null 2>&1; then
    echo -e "    $domain\n      $proto:$port"
    iptables -A OUTPUT -o eth0 -d $domain -p $proto --dport $port -j ACCEPT
elif [ "$ENABLE_IPv6" -eq 1 ] && ip -6 route get $domain > /dev/null 2>&1; then
    echo -e "    $domain\n      $proto:$port"
    ip6tables -A OUTPUT -o eth0 -d $domain -p $proto --dport $port -j ACCEPT
else
    for ip in $(dig -4 +short "$domain"); do
        echo -e "    $domain\n      IP4: $ip\n      $proto:$port"
        iptables -A OUTPUT -o eth0 -d $ip -p $proto --dport $port -j ACCEPT
        echo "$ip $domain" >> /etc/hosts
    done

    if [ "$ENABLE_IPv6" -eq 1 ]; then
        for ip in $(dig -6 +short "$domain"); do
            echo -e "    $domain\n      IP6: $ip\n      $proto:$port"
            ip6tables -A OUTPUT -o eth0 -d $ip -p $proto --dport $port -j ACCEPT
            echo "$ip $domain" >> /etc/hosts
        done
    fi
fi

echo "Allowing connections over WG interface."
iptables -A INPUT -i wg0 -j ACCEPT
iptables -A OUTPUT -o wg0 -j ACCEPT
if [ "$ENABLE_IPv6" -eq 1 ] ; then
    ip6tables -A INPUT -i wg0 -j ACCEPT
    ip6tables -A OUTPUT -o wg0 -j ACCEPT
fi

echo "Opening up forwarded ports."
if [ ! -z $FORWARDED_PORTS ]; then
    for port in ${FORWARDED_PORTS//,/ }; do
        if $(echo $port | grep -Eq '^[0-9]+$') && [ $port -ge 1024 ] && [ $port -le 65535 ]; then
            iptables -A INPUT -i wg0 -p tcp --dport $port -j ACCEPT
            iptables -A INPUT -i wg0 -p udp --dport $port -j ACCEPT
            [ "$ENABLE_IPv6" -eq 1 ] && ip6tables -A INPUT -i wg0 -p tcp --dport $port -j ACCEPT
            [ "$ENABLE_IPv6" -eq 1 ] && ip6tables -A INPUT -i wg0 -p udp --dport $port -j ACCEPT
            echo "+ port $port"
        else
            echo "- WARNING: $port is not a valid port. Ignoring."
        fi
    done
fi

echo "Blocking everything else."
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

if [ "$ENABLE_IPv6" -eq 1 ] ; then
    ip6tables -P INPUT DROP
    ip6tables -P OUTPUT DROP
    ip6tables -P FORWARD DROP
fi

echo "iptables rules created and routes configured!"
