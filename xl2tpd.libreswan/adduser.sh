#!/usr/bin/env bash
# adduser.sh

[[ $# -ne 2 ]] && echo "usage: bash adduser.sh username password" && exit 1

username=$1
password=$2

mysql -uroot -ppassword -h 127.0.0.1 --port 13306 radius -e "insert into radcheck (username,attribute,op,value) values ('${username}','Cleartext-Password',':=','${password}');"

mysql -uroot -ppassword -h 127.0.0.1 --port 13306 radius -e "insert into radusergroup (username,groupname) values ('${username}','user');"

echo "Succeeded! Add user ${username}." && exit 0
