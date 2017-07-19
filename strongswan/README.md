# Strongswan ikev2 vpn Server

## Linux Server

```shell
bash install.sh
```

## Windows 7 client

```shell
vpn.bat
```

## Linux client

    strongswan做客户端时，默认会添加一条静态路由到route table 220里，导致客户端连接以后无法访问本地IP地址。
    设置 strongswan.conf 中的 charon.install_routes = no，然后手动添加路由
