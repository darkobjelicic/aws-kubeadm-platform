#!/bin/bash
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
