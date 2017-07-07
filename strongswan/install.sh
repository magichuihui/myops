#!/bin/bash
# Install Strongswan & config ikev2 vpn

# Install dependecies
yum install -y gmp-devel

# Source code compilation
function compile() {
    tar zxvf strongswan-5.5.3.tar.gz
    cd strongswan-5.5.3
    ./configure  --sysconfdir=/etc  --enable-openssl --enable-nat-transport --disable-mysql \
        --disable-ldap  --disable-static --enable-shared --enable-md4 --enable-eap-mschapv2 \
        --enable-eap-aka --enable-eap-aka-3gpp2  --enable-eap-gtc --enable-eap-identity \
        --enable-eap-md5 --enable-eap-peap --enable-eap-radius --enable-eap-sim \
        --enable-eap-sim-file --enable-eap-simaka-pseudonym --enable-eap-simaka-reauth \
        --enable-eap-simaka-sql --enable-eap-tls --enable-eap-tnc --enable-eap-ttls
    make && make install
    return 0
}

# Download strongswan & install it
cd /usr/local/src && curl -LO https://download.strongswan.org/strongswan-5.5.3.tar.gz \
    && compile || (echo "Download strongswan failed!" && exit 1)

source /etc/profile
mkdir -p /etc/ipsec.d/certs
mkdir /etc/ipsec.d/cacerts
mkdir /etc/ipsec.d/private

# Generate keys

EXTERNAL_IP=$(ip -4 route get 1 | awk '{print $NF;exit}')

cd /tmp
ipsec pki --gen --type rsa --size 4096 --outform pem > vpnca.key.pem
ipsec pki --self --flag serverAuth --in vpnca.key.pem --type rsa --digest sha1 \
    --dn "C=CN, O=Baiyang Company, CN=Baiyang VPN CA" --ca > vpnca.crt.der

ipsec pki --gen --type rsa --size 4096 --outform pem > vpn.key.pem
ipsec pki --pub --in vpn.key.pem --type rsa > vpn.csr
ipsec pki --issue --cacert vpnca.crt.der --cakey vpnca.key.pem --digest sha1 \
    --dn "C=CN, O=Baiyang Company, CN=$EXTERNAL_IP" --san "$EXTERNAL_IP" --flag serverAuth \
    --flag ikeIntermediate --outform pem < vpn.csr > vpn.crt.pem
openssl rsa -in vpn.key.pem -out vpn.key.der -outform DER

cp vpnca.crt.der /etc/ipsec.d/cacerts/
cp vpn.crt.pem /etc/ipsec.d/certs/
cp vpn.key.der /etc/ipsec.d/private/

# Config ipsec
cat > /etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file
# basic configuration
config setup
    uniqueids=never              #允许多个客户端使用同一个证书,多设备同时在线

#所有项目共用的配置项
conn %default
    keyexchange=ike              #ikev1 或 ikev2 都用这个
    left=%any                    #服务器端标识,%any表示任意
    leftsubnet=0.0.0.0/0         #服务器端虚拟ip, 0.0.0.0/0表示通配.
    right=%any                   #客户端标识,%any表示任意

conn IKE-BASE
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    leftcert=server.cert.pem     #服务器端证书
    rightsourceip=10.0.0.0/24    #分配给客户端的虚拟 ip 段

# for IOS9 and Win 7 or later
conn ike2-eap
    also=IKE-BASE
    keyexchange=ikev2
    ike=aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=aes256-sha256,aes256-sha1,3des-sha1!
    leftsendcert=always
    leftcert=vpn.crt.pem
    leftid=$EXTERNAl_IP
    leftauth=pubkey
    leftfirewall=yes
    rightauth=eap-mschapv2
    rightsendcert=never
    eap_identity=%any
    rekey=no
    dpdaction=clear
    fragmentation=yes
    auto=add

# for IOS, use PSK key
conn IPSec-IKEv1-PSK
    also=IKE-BASE
    keyexchange=ikev1
    fragmentation=yes
    leftauth=psk
    rightauth=psk
    rightauth2=xauth
    auto=add

# for andriod
conn IPSec-xauth
    also=IKE-BASE
    leftauth=psk
    leftfirewall=yes
    right=%any
    rightauth=psk
    rightauth2=xauth
    auto=add
EOF

cat > /etc/ipsec.d/ikev2.secrets <<EOF
# for android XAUTH psk
: PSK "password"
: RSA /etc/ipsec.d/private/vpn.key.der
test : EAP "baiyang@2017"
EOF

# Start ipsec
ipsec start
