#!/usr/bin/env bash

# ----------------------------------------------------
# Restore Mysql with innobackupex
# ----------------------------------------------------

backup_dir=/home/backup/bak

source /etc/profile

dirs=`ls $backup_dir | wc -w`

# There is no backups.
if [ $dirs -lt 1 ]; then
    echo "There is no backup!"
    exit 2
fi

# -----------------------------------------------------
# Functions .
# -----------------------------------------------------

# Function for Start mysqld
function start_mysqld() {
    if [ -x /usr/bin/systemctl ]; then
        systemctl start mysqld
    elif [ -x /etc/init.d/mysql.server ]; then
        /etc/init.d/mysql.server start
    fi
}
# Function for stop mysqld
function stop_mysqld() {
    if [ -x /usr/bin/systemctl ]; then
        systemctl stop mysqld
    elif [ -x /etc/init.d/mysql.server ]; then
        /etc/init.d/mysql.server stop
    fi
}

function restore() {
    innobackupex --copy-back $1
    chown -R mysql:mysql $2
    start_mysqld
}

stop_mysqld

# Get data dir from /etc/my.cnf
data_dir=`awk -F "=" '/^datadir=/ {print $2;}' /etc/my.cnf`

# Remove the current data.
rm -rf $data_dir/*

# -----------------------------------------------
# Restore from full backup
# -----------------------------------------------
# This is only the full backup.
if [ $dirs -eq 1 ]; then

    innobackupex --apply-log $backup_dir/base
    restore $backup_dir/base $data_dir
    exit 0
fi

# -----------------------------------------------
# Restore from incremental backup
# -----------------------------------------------
# Prepare the base file
innobackupex --apply-log --redo-only $backup_dir/base

for incremental_dir in `ls $backup_dir | grep -v base | sort -nk 1 | head -n -1`; do

    echo -e "-------------------------------------------------------------------\n"
    echo "incremental_dir is $incremental_dir"
    echo -e "-------------------------------------------------------------------\n"
    innobackupex --apply-log --redo-only $backup_dir/base --incremental-dir=$backup_dir/$incremental_dir

done

last_incremental=`ls $backup_dir | grep -v base | sort -nk 1 | tail -n 1`
innobackupex --apply-log $backup_dir/base --incremental-dir=$backup_dir/$last_incremental

restore $backup_dir/base $data_dir

exit 0

