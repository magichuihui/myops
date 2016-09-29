#!/usr/bin/env bash
# radiusclient-xl2tpd.sh

# PS. this file has never been tested, use it carefully.
yum install -y radiusclient-ng*

echo -e "127.0.0.1\ttesting123-xl2tpd" >> /etc/radiusclient-ng/servers

# radiusclient.conf
sed -i 's/^authserver.*/authserver 127.0.0.1:1812/' /etc/radiusclient-ng/radiusclient.conf
sed -i 's/^acctserver.*/acctserver 127.0.0.1:1813/' /etc/radiusclient-ng/radiusclient.conf

# maybe u have to include some dictionary files to /usr/share/radiusclient-ng/dictionary, eg. dictionary.microtsoft.
# maybe u dont.


# add plugins in /etc/ppp/options.xl2tpd
echo "plugin /usr/lib64/pppd/2.4.5/radius.so" >> /etc/ppp/options.xl2tpd
echo "plugin /usr/lib64/pppd/2.4.5/radattr.so" >> /etc/ppp/options.xl2tpd

# restart the services
systemctl restart radiusd
systemctl restart xl2tpd

