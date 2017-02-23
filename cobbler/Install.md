# 实验环境

Virtualbox，网段192.168.33.0/24，host-only网络 取消dhcp服务器

Cobbler服务器 IP：192.168.33.10

# Cobbler简易配置

## 安装epel-release

```bash
yum install -y epel-release
```

## 安装相关服务

```bash
yum install -y httpd dhcp tftp cobbler cobbler-web pykickstart xinetd
systemctl start cobblerd
systemctl start httpd
systemctl start xinetd
```

## 初始化cobbler

```bash
# 检查配置文件,会列出我们需要对cobbler做的一些初始化设置
cobbler check
```

### 修改/etc/cobbler/settings配置文件

```bash
# 启动文件服务器地址
sed -i 's/^next_server: \(.*\)/next_server: 192.168.33.10/ ' /etc/cobbler/settings
# 主机服务器地址
sed -i 's/^server: \(.*\)/server: 192.168.33.10/ ' /etc/cobbler/settings
```

### 开启tftp服务

```bash
sed -i 's/\(disable.*\)yes/\1no/' /etc/xinetd.d/tftp
```

### 下载网络引导文件

```bash
cobbler get-loaders
```

### 开启rsyncd

```bash
systemctl start rsyncd
```

### 创建系统初始化后的root密码

```bash
sed -i 's/^\(default_password_crypted: "\).*\("\)$/\1'`openssl passwd -1 -salt 'ahdui123;k' 'password'`'\2/g' /etc/cobbler/settings

# 再次检查
cobbler check
```

## 使用cobbler管理dhcp

```bash
# 启用dhcp管理
sed -i 's/^manage_dhcp: 0/manage_dhcp: 1/g' /etc/cobbler/settings

# 修改dhcp模板
sed -i 's/127.0.0.1/192.168.33.10/g' /etc/cobbler/dhcp.template
```

## 重启cobbler，并sync

```bash
systemctl restart cobblerd
cobbler sync
```

## 添加系统镜像

```bash
# 挂载iso文件
mkdir /mnt/centos
mount -o loop -t iso9660 /vagrant_data/CentOS-7-x86_64-DVD-1611.iso /mnt/centos
# 导入镜像
cobbler import --path=/mnt/centos --name=/CentOS7-x86_64 --arch=x86_64

# 修改内核选项，（否则会出现can't mount root filesystem）
cobbler profile edit --name=CentOS7-x86_64 --kopts="ksdevice= inst.repo="http://192.168.33.10/cblr/ks_mirror/CentOS7-x86_64"

cobbler profile list
cobbler profile report

# 上传kickstart文件，并修改cobbler的默认ks配置
cobbler profile edit --name=CentOS7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/ks.cfg

# 这里没有试过，修改内核文件参数，让centos7初始化网卡名为“eth”
#cobbler profile edit --name=CentOS7-x86_64 --kopts='net.ifnames=0 biosdevname=0'

cobbler sync


