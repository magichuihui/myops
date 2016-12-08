#!/usr/bin/env bash

mysql -uroot -ppassword -e "CREATE USER 'bkpuser'@'localhost' IDENTIFIED BY 's3cret';"

mysql -uroot -ppassword -e "GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO
'bkpuser'@'localhost'; FLUSH PRIVILEGES;"
