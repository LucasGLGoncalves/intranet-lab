#!/bin/bash
set -e

ip link add dev wg0 type wireguard || true
ip address add dev wg0 10.10.0.1/24 || true
wg setconf wg0 /etc/wireguard/wg0.conf
ip link set up dev wg0

exec tail -f /dev/null