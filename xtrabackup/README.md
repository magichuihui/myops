## MySQL backup strategy

### Scripts usage.

backup-hourly.sh        Backup mysql per hour.

backup.sh               Backup mysql per day.

backupuser.sh           Create an user on mysql for backup

restore.sh              Restore Mysql

### How to use this via crontab.

echo "1 * * * * root bash /root/xtrabackup/backup-hourly.sh > /dev/null 2>&1" >> /etc/crontab

