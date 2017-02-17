# Vagrant安装与配置

## Vagrant是什么

Vagrant是用来构建虚拟开发环境的工具，支持Virtualbox，VMware等做为虚拟机系统

## Vagrant能做什么

* 统一开发环境。一次配置打包，统一分发给团队成员，统一团队开发环境，解决诸如“编码问题”，“配置文件不同”, “在我的电脑上可以运行”等问题。

* 避免重复搭建开发环境。新员工加入，不用浪费时间搭建开发环境，快速加入开发，减少时间成本的浪费。

* 多个相互隔离开发环境。可以在不用box里跑不同的语言，或者编译安装同一语言不同版本，搭建多个相互隔离的开发环境，卸载清除时也很快捷轻松。


## 主机环境

* windowns 7 专业版

* [cygwin] http://www.cygwin.com/ 

* [VirtualBox] https://www.virtualbox.org/wiki/Downloads

* [Vagrant] https://www.vagrantup.com/downloads.html

## 常用命令

### 添加box

    # box是已经打包好的虚拟机镜像，可以从网站上下载，也可以自己打包生成
    # ./CentOS-7-x86_64-Vagrant-1611_01.VirtualBox.box 是提前下载好的文件
    vagrant box add CentOS7 ./CentOS-7-x86_64-Vagrant-1611_01.VirtualBox.box

    # box文件也可以是远程地址
    # vagrant box add base https://atlas.hashicorp.com/hashicorp/boxes/precise64/versions/1.1.0/virtualbox.box

### 查看已安装的box

    # 查看本机已经安装的box, 其中CentOS7即为我们刚才安装的box
    vagrant box list
    
    # CentOS7             (virtualbox, 0)
    # freebsd             (virtualbox, 0)
    # hashicorp/precise64 (virtualbox, 1.1.0)
    # mybox               (virtualbox, 0)

### 初始化

    # 进入目录
    # cd /cygdrive/d/boxes; mkdir vagrant_getting_started;
    # 初始化一个CentOS7的虚拟机
    vagrant init CentOS7

    # 此时会在当前目录里生成一个Vagrantfile，里面有大量的配置信息

### 启动虚拟机

    vagrant up

### ssh到虚拟机
    
    vagrant ssh

### 重启虚拟机（重新加载配置文件）
    
    vagrant reload

### 打包分发

    vagrant package --output mybox.box --vagrantfile Vagrantfile

## Vagrantfile配置

开发目录下的 Vagrantfile 含有大量的配置信息，主要包括三个方面，虚拟机的配置、SSH配置、Vagrant的一些基础配置。
注释比较全，以下是一些常用的配置

### box设置

    # box的名字
    config.vm.box = "CentOS7"

### hostname设置

    config.vm.hostname = "localhost"

### 虚拟机的网络设置

    # 虚拟机默认第一个网卡是NAT模式，这是为方便ssh登录，不能更改。我们可以再添加另外的网卡
    # host-only 网络
    config.vm.network "private_network", ip: "192.168.33.10"
    # 桥接网络，即宿主机跟虚拟机在同一个网段
    config.vm.network "public_network"

    # 端口转发
    config.vm.network "forwarded_port", guest: 80, host: 8080

### 同步目录
    
    # 同步目录跟Virtualbox的共享文件夹是同一个东西，所以要使用这个功能虚拟机上必须安装VBOXGuestAdditions(设备->安装增加功能)
    config.vm.synced_folder "./www", "/var/www/html"
