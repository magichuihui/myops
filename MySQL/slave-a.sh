#!/usr/bin/env bash
# slave-a.sh

# 1. Lock master-a's table
mysql -uroot -ppassword -hmaster-a.baiyjk.com -e "FLUSH TABLE WITH READ LOCK;SELECT SLEEP(120);"

# 2. Configure slave-a's my.cnf
sed -i '/\[mysqld\] a server-id=11' /etc/my.cnf
systemctl restart mysqld.service

# 3. Obtain master-a's binary log coordinate
str=$(mysql -uroot -ppassword -hmaster-a.baiyjk.com -e "SHOW MASTER STATUS;" 2>/dev/null | grep mysql-bin)
arr=($str)
log_file=${arr[0]}
log_pos=${arr[1]}
# Change master on slave-a
mysql -uroot -ppassword -h127.0.0.1 -e "CHANGE MASTER TO \
    MASTER_HOST='master-a.baiyjk.com',\
    MASTER_USER='repl', \
    MASTER_PASSWORD='replication', \
    MASTER_LOG_FILE='${log_file}', \
    MASTER_LOG_POS='${log_pos}'; \
    START SLAVE;"
