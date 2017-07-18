#!/bin/bash

echo "password" > /etc/rsyncd.pass

chmod 0600 /etc/rsyncd.pass

sh /root/rsync.sh
