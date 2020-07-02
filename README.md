
## Webvirtmgr Dockerfile

1. Install [Docker](https://www.docker.com/).

2. Pull the image from Docker Hub

3. Create volume for data
```
$ docker pull flexible1983/webvirtmgr-docker
$ docker volume create webvirtmgr-data
```

### Usage

```
$ docker run -d \
  -p 8080:8080 -p 6080:6080 \
  -v webvirtmgr-data:/data \
  --name webvirtmgr \
  flexible1983/webvirtmgr-docker
```

### libvirtd configuration on the host

```
$ cat /etc/default/libvirt-bin
start_libvirtd="yes"
libvirtd_opts="-d -l"
```

```
$ cat /etc/libvirt/libvirtd.conf
listen_tls = 0
listen_tcp = 1
listen_addr = "172.17.42.1"  ## Address of docker0 veth on the host
unix_sock_group = "libvirtd"
unix_sock_ro_perms = "0777"
unix_sock_rw_perms = "0770"
auth_unix_ro = "none"
auth_unix_rw = "none"
auth_tcp = "none"
auth_tls = "none"
```

```
$ cat /etc/libvirt/qemu.conf
# This is obsolete. Listen addr specified in VM xml.
# vnc_listen = "0.0.0.0"
vnc_tls = 0
# vnc_password = ""
```