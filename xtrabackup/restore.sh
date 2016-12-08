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

function restore() {
    innobackupex --copy-back $1
    chown -R mysql:mysql $2
    systemctl start mysqld
}

systemctl stop mysqld

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

for ((i=1; i<$dirs-1; i++ )); do

    innobackupex --apply-log --redo-only $backup_dir/base --incremental-dir=$backup_dir/$i

done

innobackupex --apply-log $backup_dir/base --incremental-dir=$backup_dir/$i

restore $backup_dir/base $data_dir

exit 0
