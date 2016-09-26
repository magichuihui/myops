#!/usr/bin/env bash
# firewalld.sh

# restart firewalld
systemctl restart firewalld

# add ipsec service
firewall-cmd --add-service=ipsec --permanent
cp /lib/firewalld/services/ipsec.xml /etc/firewalld/services
sed -i '/port="500"/ a \ \ <port protocol="udp" port="4500" \/>' /etc/firewalld/services/ipsec.xml

# add xl2tpd service
firewall-cmd --new-service=xl2tpd --permanent
sed -i '/<service>/ a \\t<short>xl2tpd<\/short>\n\t<port protocol="udp" port="1701" \/>' /etc/firewalld/services/ipsec.xml
firewall-cmd --add-service=xl2tpd --permanent

# add masquerade
firewall-cmd --add-masquerade --permanent

firewall-cmd --reload
