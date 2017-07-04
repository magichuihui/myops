#!/usr/bin/env bash
# ipsec.sh

# install libreswan
yum install -y nss-devel nspr-devel pkgconfig pam-devel \
    libcap-ng-devel libselinux-devel \
    curl-devel flex bison gcc make \
    fipscheck-devel unbound-devel libevent-devel xmlto

yum install -y audit-libs-devel systemd-devel git wget unzip

cd /usr/local/src && wget https://github.com/libreswan/libreswan/archive/master.zip && unzip master.zip && cd libreswan-master && make programs && make install && cd .. && rm -rf libreswan-master


# config sysctl
echo "1" > /proc/sys/net/ipv4/ip_forward

for each in /proc/sys/net/ipv4/conf/*
do
    interface_name=$(basename $each)
    echo "net.ipv4.conf.${interface_name}.rp_filter=0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.${interface_name}.send_redirects=0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.${interface_name}.accept_redirects=0" >> /etc/sysctl.conf
done

sysctl -p

# ipsec configure

PRIVATE_IP=$(ip -4 route get 1 | awk '{print $NF;exit}')


cat > /etc/ipsec.d/l2tp_vpn.conf <<EOF
config setup
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
    oe=off
    protostack=netkey

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=$PRIVATE_IP
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF


echo -e "${PRIVATE_IP} %any: PSK \"password\"" > /etc/ipsec.d/l2tp_vpn.secrets

# start ipsec.service
systemctl start ipsec.service
systemctl enable ipsec.service

ipsec verify
