#!/bin/bash

# This script will backup mysql database

mysql_dir=/var/mysql/data
backup_dir=/mydata/mysql_backup/backup
binlog=mysql-bin
host=192.168.0.226
day_of_week=$(date +"%w")
week_of_year=$(date +"%U")

# enter mysql data directory
cd $mysql_dir

mkdir $backup_dir/$week_of_year

# Copy binlog file 
mysqladmin -ubackup -ppassword -h$host flush-logs binary
cp `tac $binlog.index | sed -n '2p'` $backup_dir/$week_of_year

# when Sunday, make an full backup
if [ $day_of_week -eq 0 ]; then

    # delete binlogs except the last one
    rm -f `sed -n '$!p' $mysql_dir/$binlog.index`

    # backup db
    mysqldump -ubackup -ppassword -h$host --all-databases --single-transaction --quick > $backup_dir/$week_of_year/`date +"%Y%m%d"`.sql

    # delete the last binlog
    #rm -f `sed -n '$p' $mysql_dir/$binlog.index`

    # create new binlog by flush logs
    #mysqladmin -ubackup -ppassword -h$host flush-logs binary

    # write new binlog info to mysql-bin.inex
    sed -i '$ !d' $mysql_dir/mysql-bin.index

fi

exit 0
