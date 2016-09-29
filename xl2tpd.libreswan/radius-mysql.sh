#!/usr/bin/env bash
# radius-mysql.sh

# usage: bash radius-mysql.sh host port user passwd
[[ $# -ne 4 ]] && echo "usage: bash radius-mysql.sh host port user passwd" && exit 1

host=$1
port=$2
user=$3
password=$4

# create database radius
mysql -u$user -p$password -h $host --port $port -e 'CREATE DATABASE IF NOT EXISTS radius;'

# create database account
sed -i "s/localhost/%/" /etc/raddb/mods-config/sql/main/mysql/setup.sql
mysql -u$user -p$password -h $host --port $port radius < /etc/raddb/mods-config/sql/main/mysql/setup.sql

# create schema
mysql -u$user -p$password -h $host --port $port radius < /etc/raddb/mods-config/sql/main/mysql/schema.sql

# create a test user
mysql -u $user -p$password -h $host --port $port radius -e "insert into radgroupreply (groupname,attribute,op,value) values ('user','Auth-Type',':=','Local');"
mysql -u $user -p$password -h $host --port $port radius -e "insert into radgroupreply (groupname,attribute,op,value) values ('user','Service-Type',':=','Framed-User');"
mysql -u $user -p$password -h $host --port $port radius -e "insert into radgroupreply (groupname,attribute,op,value) values ('user','Framed-IP-Address',':=','255.255.255.255');"
mysql -u $user -p$password -h $host --port $port radius -e "insert into radgroupreply (groupname,attribute,op,value) values ('user','Framed-IP-Netmask',':=','255.255.255.0');"

mysql -u $user -p$password -h $host --port $port radius -e "insert into radcheck (username,attribute,op,value) values ('test','Cleartext-Password',':=','testpwd');"

mysql -u $user -p$password -h $host --port $port radius -e "insert into radusergroup (username,groupname) values ('test','user');"

# change time value to int
mysql -u $user -p$password -h $host --port $port radius -e "alter table radacct modify acctstarttime int unsigned, modify acctupdatetime int unsigned, modify acctstoptime int unsigned;"

# config mod mysql
cd /etc/raddb/mods-enabled/
ln -s ../mods-available/sql
chown root:radiusd sql 
sed -i 's/driver = "rlm_sql_null"/driver = "rlm_sql_mysql"/' sql
sed -i "s/^#.server.*/\tserver = \"$host\"/" sql
sed -i "s/^#.port.*/\tport = $port/" sql
sed -i 's/^#.login.*/\tlogin = "radius"/' sql
sed -i 's/^#.password.*/\tpassword = "radpass"/' sql

# config radius client(/etc/raddb/clients.conf)
PRIVATE_IP=$(ip -4 route get 1 | awk '{print $NF;exit;} -)
echo -e "client xl2tpd {\n\tipaddr\t\t= ${PRIVATE_IP}\n\tsecret\t\t= testing123-xl2tpd\n}" >> /etc/raddb/clients.conf

# start radius server
systemctl start radiusd
systemctl enable radiusd
