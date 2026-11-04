#!/bin/bash
# This script is used to enable NAT on a Linux system using nftables. 
# It configures the system to forward IPv4 packets and sets up a NAT table with a 
# POSTROUTING chain that masquerades outgoing traffic on the eth0 interface. 
# The script also enables and starts the nftables service to apply the configuration.
set -euxo pipefail

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-nat.conf
sysctl --system

cat <<EOF >> /etc/sysconfig/nftables.conf
table ip nat {
    chain POSTROUTING{
        type nat hook postrouting priority 100;
        oifname "eth0" masquerade
    }
}
EOF

systemctl enable --now nftables
