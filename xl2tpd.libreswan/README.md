# install

## First step

```bash
# bash ipsec.sh
```

## Next step

```bash
# bash xl2tpd.sh
```

## Final

```bash
# bash firewalld.sh
```

> In case u want to authenticate by radius server, the example here runs mysqld in a docker container which exposed the port 13306.

```bash
# bash radius-mysql.sh 127.0.0.1 13306 root password
# bash radiusclient-xl2tpd.sh
```
