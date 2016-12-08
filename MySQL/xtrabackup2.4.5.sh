#!/usr/bin/env bash

# ----------------------------------------------------------
# Install percona Xtrabackup
# ----------------------------------------------------------
xtrabackup=percona-xtrabackup-2.4.5
mysqlversion=5.7.15


yum install -y cmake gcc gcc-c++ libaio libaio-devel automake autoconf \
bison libtool ncurses-devel libgcrypt-devel libev-devel libcurl-devel \
vim-common

#yum install epel-release && yum install libev

# assume that there are mysql-boost-5.7.15.tar.gz and percona-xtrabackup-2.4.5.tar.gz in /usr/local/src
cd /usr/local/src
# extract mysql and xtrabackup
tar zxvf mysql-boost-$mysqlversion.tar.gz
tar zxvf $xtrabackup.tar.gz

cd $xtrabackup
cmake -DBUILD_CONFIG=xtrabackup_release -DWITH_BOOST=../mysql-$mysqlversion/boost/ -DWITH_MAN_PAGES=OFF && make -j4
make install



