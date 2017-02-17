#!/usr/bin/env bash

# ------------------------------------------------------------------------
# MySQL Backup strategy
# 
# Use xtrabackup to backup MySQL' data.
# Every day we make a full backup, and every hour make an incremental backup.
# Xtrabackup的使用参考了老司机王海的《研究内容汇报.doc》
# ------------------------------------------------------------------------

# Set backup directory.
backup_dir=/home/backup

today=`date +%Y-%m-%d`
yesterday=`date -d "yesterday" +"%Y-%m-%d"`
declare -i current_hour=`date +"%-H"`

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

# Move yesterday's backup to Archive.
function archive_yesterday() {
    yesterday=`date -d "yesterday" +"%Y-%m-%d"`
    backup_dir=$1
    
    tar zcvf $backup_dir/archive/$yesterday.tar.gz $backup_dir/bak
    rm -rf $backup_dir/bak/*
}

# -----------------------------------------------------------------------
# Start to backup
# -----------------------------------------------------------------------
# The first time we backup mysql, use a full backup.
if [ ! -d base ]; then

    mkdir base
    full_backup $backup_dir/bak/base
    exit 0

fi

# In a new day, we archive yesterday's backup and then make a full backup.
if [ $current_hour -eq 0 ]; then

    archive_yesterday $backup_dir
    full_backup $backup_dir/bak/base
    exit 0

fi

# In another hours besides zero, we make an incremental backup.
incremental_basedir=$backup_dir/bak/base
declare -i previous_hour=$current_hour-1

if [ -d $previous_hour ]; then
    incremental_basedir=$backup_dir/bak/$previous_hour
fi
echo $incremental_basedir
mkdir $current_hour
incremental_backup $backup_dir/bak/$current_hour $incremental_basedir

exit 0
