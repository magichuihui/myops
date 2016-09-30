#!/usr/bin/env bash
# master-a.sh

# this script has not been tested yet.
# 1. Configure Master-a's my.cnf
sed -i '/\[mysqld\]/ a log-bin=mysql-bin\nserver-id=1\ninnodb_flush_log_at_trx_commit=1\nsync_binlog=1' /etc/my.cnf

# 2. Create user repl on master-a for replication
mysql -uroot -ppassword -h127.0.0.1 -e "CREATE USER 'repl'@'192.168.137.0/24' IDENTIFIED BY 'replication';GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.137.0/24';"

mysql -uroot -ppassword -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%.baiyjk.com' IDENTIFIED BY 'password';"

systemctl restart mysqld.service

 

