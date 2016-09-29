# install NFS server
yum install -y rpcbind nfs-utils
systemctl start rpcbind nfs-server
systemctl enable rpcbind nfs-server

# make some directories for example
mkdir -p /home/kyra/nfs-test
mkdir /export
mkdir /export/nfs-test

mount --bind /home/kyra/nfs-test /export/nfs-test
echo "/home/kyra/nfs-test   /export/nfs-test    none    bind    0 0" >> /etc/fstab

# export the shared filesystem
echo -e "/export\t\t\t\t192.168.0.0/16(rw,fsid=0,no_subtree_check,sync,no_root_squash,no_all_squash,insecure)\n/export/nfs-test\t192.168.0.0/16(rw,nohide,no_subtree_check,sync,no_root_squash,no_all_squash,insecure)" >> /etc/exports
exportfs -rv
