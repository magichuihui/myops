#!/usr/bin/env bash

# ------------------------------------------------------------------------
# MySQL Backup strategy
# 
# Use xtrabackup to backup MySQL' data.
# Every week we make a full backup, and every day make an incremental backup.
# Xtrabackup的使用参考了老司机王海的《研究内容汇报.doc》
# ------------------------------------------------------------------------

# Set backup directory.
backup_dir=/home/backup

today=`date +%Y-%m-%d`

mkdir -p $backup_dir/bak $backup_dir/archive

cd $backup_dir/bak

# Load env set in /etc/profile
source /etc/profile

# ----------------------------------------------------------------------
# Functions for backup.
# ----------------------------------------------------------------------
# Full backup
function full_backup() {
    innobackupex $1 --no-timestamp    
}

function incremental_backup() {
    innobackupex --incremental $1 --incremental-basedir=$2 --no-timestamp
}

# The first time we backup mysql, use a full backup.
if [ ! -d base ]; then

    mkdir base
    full_backup $backup_dir/bak/base
    exit 0

fi

# Then, we use an incremental backup base on the full backup or 
# an incremental backup the last day.
incremental_basedir=$backup_dir/bak/base

for ((i=1; i<7; i++)); do
    
    if [ ! -d $i ]; then
        
        mkdir $i
        incremental_backup $backup_dir/bak/$i $incremental_basedir
        exit 0        

    fi

    incremental_basedir=$backup_dir/bak/$i

done

cd ..
tar zvcf backup-$today.tar.gz bak
rm -rf $backup_dir/archive/*
rm -rf $backup_dir/bak/*
mv backup-$today.tar.gz archive

# full backup
mkdir $backup_dir/bak/base
full_backup $backup_dir/bak/base

exit 0
