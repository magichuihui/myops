#!/bin/bash

## Migrate svn serve from 58's server

### Checkout
cd /data
svn checkout svn://58.63.114.90/svn
find svn -name ".svn" | xargs rm -rf

### Install svn package
yum install -y httpd subversion mod_dav_svn

### Create a new repository
mkdir /data/svndata
svnadmin create /data/svndata/svn
chown -R apache:apache /data/svndata/svn

cd /data/svndata/svn
cat > conf/svnserve.conf <<EOF
anon-access = none
auth-access = write
password-db = passwd
authz-db = authz

EOF

cat > conf/passwd <<EOF
[users]
test = password
kyra = password
EOF

cat > conf/authz <<EOF
[groups]
admin = test,kyra

[svn:/]
@admin = rw
*=
EOF

# setup http pasword
htpasswd -b -m -c conf/httppass test password
htpasswd -b -m -c conf/httppass kyra password

# Config httpd
cat >> /etc/httpd/conf.d/subversion.conf <<EOF
<Location /repos>
   DAV svn
   SVNParentPath /data/svndata

   # Limit write permission to list of valid users.
   <LimitExcept GET PROPFIND OPTIONS REPORT>
      # Require SSL connection for password protection.
      # SSLRequireSSL

      AuthType Basic
      AuthName "Authorization Realm"
      #AuthzSVNAccessFile /data/svndata/svn/conf/authz
      AuthUserFile /data/svndata/svn/conf/httppass
      Require valid-user
   </LimitExcept>
</Location>
EOF

# SElinux
chcon -R -t httpd_sys_content_t /data/svndata/svn
chcon -R -t httpd_sys_rw_content_t /data/svndata/svn

# Strat snvserve
svnserve -d -r /data/svndata/svn
# Restart httpd
service httpd restart
