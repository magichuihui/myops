## MySQL backup strategy

### File usage.

backup-hourly.sh        Backup mysql per hour.
backup.sh               Backup mysql per day.
backupuser.sh           Create an user on mysql for backup
restore.sh              Restore Mysql

### How to use.
echo "1 * * * * root bash /root/xtrabackup/backup-hourly.sh > /dev/null 2&>1" >> /etc/crontab

