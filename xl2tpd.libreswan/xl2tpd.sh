#!/usr/bin/env bash
# xl2tpd.sh

# install xl2tpd
yum install -y xl2tpd

# xl2tpd configrue
if [ -f /etc/xl2tpd/xl2tpd.conf ]; then
  
    sed -i ' /\[global\]/ a ipsec saref = yes' /etc/xl2tpd/xl2tpd.conf
    sed -i ' /ip range/ c ip range = 10.0.1.2-10.0.1.254' /etc/xl2tpd/xl2tpd.conf
    sed -i ' /local ip/ c local ip = 10.0.1.1' /etc/xl2tpd/xl2tpd.conf
  
else
    cat >> /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = yes

[lns default]
ip range = 10.0.1.2-10.0.1.254
local ip = 10.0.1.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

fi

cat > /etc/ppp/options.xl2tpd <<EOF
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
EOF

# username, password
echo -e "username * password *" >> /etc/ppp/chap-secrets


# start xl2tpd
systemctl start xl2tpd
systemctl enable xl2tpd

