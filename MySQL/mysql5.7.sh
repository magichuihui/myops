#!/usr/bin/env bash
# mysql5.7.sh

yum makecache fast && yum update -y && yum install -y wget gcc-c++ ncurses-devel cmake make perl gcc autoconf automake zlib libxml libgcrypt libtool bison
yum remove -y mariadb*

# assume there is a mysql-boost-5.7.15.tar.gz file in /usr/local/src
cd /usr/local/src
wget http://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.15.tar.gz
tar zxvf mysql-boost-5.7.15.tar.gz

# add mysql user and group
groupadd mysql
useradd -r -g mysql -s /bin/false mysql

# build souce
cd mysql-5.7.15 && mkdir bld && cd bld

cmake .. \
    -DWITH_BOOST=../boost \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_EXTRA_CHARSETS=all \
    -DWITH_SYSTEMD=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DMYSQL_DATADIR=/var/mysql/data

make && make install && cd /usr/local/src && rm -rf mysql-5.7.15

#
cd /usr/local/mysql
chown -R mysql:mysql .

# systemd configure
cp -r usr/* /usr
cp support-files/my-default.cnf /etc/my.cnf
systemctl enable mysqld

# initialize mysqld
bin/mysqld --initialize-insecure --user=mysql
chown -R root .
bin/mysqld --user=mysql &

# wait for mysqld
sleep 15

bin/mysql -uroot -h127.0.0.1 -e "SET PASSWORD FOR 'root'@'localhost' = password('password');"
cp support-files/mysql.server /etc/init.d/mysql.server

# remove the old kernel
cat >> /usr/lib/systemd/system/rm-old-kerneld.service <<EOF
[Service]
ExecStart=/bin/bash /root/rm-old-kernel.sh

[Install]
WantedBy=multi-user.target

EOF

cat >> /root/rm-old-kernel.sh <<EOF
#!/usr/bin/env bash

rpm -qa | grep kernel | awk '\$1 !~ /.*36.1/' | xargs yum remove -y

systemctl disable rm-old-kerneld.service

rm -f /usr/lib/systemd/system/rm-old-kerneld.service

rm -f /root/rm-old-kernel.sh

EOF

systemctl enable rm-old-kerneld.service

# add mysql PATH
echo -e '\nPATH=/usr/local/mysql/bin:$PATH' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile

# reboot
reboot

