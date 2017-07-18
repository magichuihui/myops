#!/bin/bash

# rsync server
yum update -y rsync

cat > /etc/rsyncd.conf <<EOF
uid = nobody
gid = nobody
use chroot = no
max connections = 200
timeout = 600
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
log file = /var/log/rsyncd.log

[baiyang_subject]
path = /tmp/dest
ignore errors
read only = no
write only = no
hosts allow = *
list = false
uid = root
gid = root
auth users = backup
secrets file = /etc/rsyncd.pass
EOF

echo "backup:password" >> /etc/rsyncd.pass

# Restart rsyncd
service rsyncd restart
