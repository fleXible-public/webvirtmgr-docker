
# Webvirtmgr Dockerfile

* webvirtmgr version: `v4.8.9`

1. Install [Docker](https://www.docker.com/)
2. Pull the image from Docker Hub
3. Create volume for persistent data
```
$ docker pull flexible1983/webvirtmgr-docker
$ docker volume create webvirtmgr-data
```

## Usage

```
$ docker run -d \
  -p 8080:8080 \
  -p 6080:6080 \
  -v webvirtmgr-data:/data \
  --name webvirtmgr \
  flexible1983/webvirtmgr-docker
```

To use local socket for libvirtd, bind mount the socket to `/var/run/libvirt/libvirt-sock`.

```
$ docker run -d \
  -p 8080:8080 \
  -p 6080:6080 \
  -v webvirtmgr-data:/data \
  -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
  --name webvirtmgr \
  flexible1983/webvirtmgr-docker
```

Create an admin user if running with new volume.
```
$ docker exec -ti webvirtmgr /webvirtmgr/manage.py createsuperuser
```

## libvirtd configuration on the host

### Local Socket

No special changes are necessary.

### SSH connection

Follow official [Setup-SSH-Authorization](https://github.com/retspen/webvirtmgr/wiki/Setup-SSH-Authorization) 
guide and put the resulting `.ssh` directory in your data volume.

```
$ export DATA=$(docker volume inspect webvirtmgr-data | jq ".[]|.Mountpoint")
$ cp -rv .ssh $DATA
```

### TCP connection

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
