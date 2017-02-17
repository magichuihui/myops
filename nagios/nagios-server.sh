#!/usr/bin/env bash

# ----------------------------------------------------------------------------
#
# Install Script for the Nagios Server
#
# You can find more information on 
#   http://www.ibm.com/developerworks/cn/linux/1309_luojun_nagios/
#
# ----------------------------------------------------------------------------

# Set Nagios's version.
nagios=nagios-4.2.3
plugins=nagios-plugins-2.1.4
nrpe=nrpe-3.0.1
pnp4nagios=pnp4nagios-0.6.25
mail=sendEmail-v1.56

# ----------------------------------------------------------------------------
# Step 0. Install dependencies
# ----------------------------------------------------------------------------
yum install -y gd fontconfig-devel libjpeg-devel libpng-devel gd-devel perl-GD \
    openssl-devel php mailx postfix cpp gcc gcc-c++ libstdc++ glib2-devel \
    libtoul-ltdl-devel

# New user and groups for Nagios
groupadd -g nagcmd
useradd -g nagios -G nagcmd -m nagios

# Install httpd & php
yum install -y httpd php*
usermod -a -G nagios,nagcmd apache


# ----------------------------------------------------------------------------
# Step 1. Install nagios core
# ----------------------------------------------------------------------------
# Assume all the source file is already in /usr/local/src.
# make & make install
cd /usr/local/src
tar zxvf $nagios.tar.gz
cd $nagios
./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios --with-command-user=nagios --with-command-group=nagcmd --enable-event-broker --enable-nanosleep --enable-embedded-perl --with-perlcache

make all
make install
make install-init
make install-commandmode
make install-webconf
make install-config

htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin password


# ----------------------------------------------------------------------------
# Step 2. Install nagios plugins
# ----------------------------------------------------------------------------

# Install other packages only if we are going to use some extra plugins(mysql, etc).
yum install -y mariadb-libs mariadb-devel

cd /usr/local/src/
tar zxvf $plugins.tar.gz
cd $plugins
./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install
#chomd -R 0755 /usr/local/nagios

# Check nagios's configure.
echo "alias nagioscheck='/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg'" >> /root/.bashrc
source /root/.bashrc

# Start Nagios Service
systemctl enable httpd
systemctl enable nagios
systemctl restart httpd
systemctl restart nagios

# ----------------------------------------------------------------------------
# Step 3. Install pnp4nagios
# ----------------------------------------------------------------------------
yum install rrdtool perl-Time-HiRes rrdtool-perl php-gd
cd /usr/local/src
tar zxvf $pnp4nagios.tar.gz
cd $pnp4nagios
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make all
make fullinstall

curl -u nagiosadmin:password -s http://127.0.0.1:8008/install.php
mv /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.bak

# Copy from /usr/local/pnp4nagios/etc/nagios.cfg-sample to /usr/local/nagios/etc/nagios.cfg
echo -e "\n\n" >> /usr/local/nagios/etc/nagios.cfg
awk 'BEGIN {start=0;recoding=0;}
{
    if (start == 0) {
        if ($0 ~ /^#$/) {
            start = 1;
            res=$0;
        }
    } else {
        if (recording == 0) {
            if ($0 ~ /^# Bulk \/ NPCD mode/) {
                recording=1;
                print res;
                print $0;
            } else {
                start=0;
                res="";
            }
        } else {
            res="";
            print $0;
            if ($0 ~ /host_perfdata_file_processing_command/) {start=0;recording=0;}
         }
    }
}
' /usr/local/pnp4nagios/etc/nagios.cfg-sample >> /usr/local/nagios/etc/nagios.cfg

# Edit /usr/local/nagios/etc/objects/commands.cfg
awk 'BEGIN {start=0;recoding=0;}
{
    if (start == 0) {
        if ($0 ~ /^#$/) {
            start = 1;
            res=$0;
        }
    } else {
        if (recording == 0) {
            if ($0 ~ /^# Bulk with NPCD mode/) {
                recording=1;
                print res;
                print $0;
            } else {
                start=0;
                res="";
            }
        } else {
            print $0;
         }
    }
}
' /usr/local/pnp4nagios/etc/misccommands.cfg-sample | sed '4,$ s/^#\(.*\)/\1/' >> /usr/local/nagios/etc/objects/commands.cfg

# Edit /usr/local/nagios/etc/objects/templates.cfg
cat >> /usr/local/nagios/etc/objects/templates.cfg <<'EOF'
define host {
name host-pnp
action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=_HOST_
register 0
}
define service {
name srv-pnp
action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=$SERVICEDESC$
register 0
}
EOF

# Install mail client.
tar zxvf $mail.tar.gz
cp $mail/sendEmail /usr/bin

# --------------------------------------------------------------------------------
# Step 4. Install NRPE.
# --------------------------------------------------------------------------------
tar zxvf $nrpe.tar.gz
cd $nrpe
./configure && make all
make install-plugin
make install-daemon
make install-init
make install-config

cat >> /usr/local/nagios/etc/monitor/commands.cfg <<'EOF'

# check_nrpe
define command {
    command_name check_nrpe
    command_line /usr/local/nagios/libexec/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
EOF

# --------------------------------------------------------------------------------
# Step 4. Restart npcd & nagios. Enjoy!
# --------------------------------------------------------------------------------
systemctl enable npcd
systemctl enable nrpe
systemctl restart nrpe
systemctl restart npcd
systemctl restart nagios
