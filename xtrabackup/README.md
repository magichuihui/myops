## MySQL backup strategy

### Scripts usage.

```bash
# Backup mysql databases per hour.
backup-hourly.sh

# Backup mysql databases per day.
backup.sh

# Create an mysql user for backup.
backupuser.sh

# Restore from backups
restore.sh
```

### How to use this via crontab.

```bash
echo "1 * * * * root bash /root/xtrabackup/backup-hourly.sh > /dev/null 2>&1" >> /etc/crontab
```
