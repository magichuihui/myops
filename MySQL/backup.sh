#!/bin/bash

# This script will backup mysql database

mysql_dir=/var/mysql/data
backup_dir=/mydata/mysql_backup/backup
binlog=mysql-bin
host=192.168.0.226
declare -i day_of_week=$(date +"%w")
declare -i week_of_year=$(date +"%U")

# enter mysql data directory
cd $mysql_dir

mkdir -p $backup_dir/$week_of_year

# On Weekday or Saturday, flush binlog
if [ $day_of_week -gt 0 ]; then

    # Flush & copy binlog file 
    mysqladmin -ubackup -ppassword -h$host flush-logs binary
    cp `tac $binlog.index | sed -n '2p'` $backup_dir/$week_of_year

fi

# when Sunday, make an full backup
if [ $day_of_week -eq 0 ]; then

    # If it's the first Sunday in a year, move the binlog file to parent directory
    if [ $week_of_year -eq 0 ]; then
        last_backup_dir=""
    else
        declare -i last_backup_dir=$week_of_year-1
    fi

    mkdir -p $backup_dir/$last_backup_dir

    # backup db
    mysqldump -ubackup -ppassword -h$host --all-databases --single-transaction --flush-logs --quick --master-data=2 > $backup_dir/$week_of_year/`date +"%Y%m%d"`.sql

    # Copy the last week's binlog
    cp `tac $binlog.index | sed -n '2p'` $backup_dir/$last_backup_dir

    # delete binlogs except the last one
    rm -f `sed -n '$!p' $mysql_dir/$binlog.index`

    # write new binlog info to mysql-bin.inex
    sed -i '$ !d' $mysql_dir/mysql-bin.index

fi

exit 0
