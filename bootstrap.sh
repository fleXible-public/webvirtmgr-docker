#!/bin/bash
set -o errexit    # exit on error
set -o pipefail   # exit on error in pipe
set -o nounset    # exit on undefined variable

if [[ -S "/var/run/libvirt/libvirt-sock" ]]; then
  read -r gid group < <(stat -c "%g %G" "/var/run/libvirt/libvirt-sock")
  if [[ $group != "libvirtd" ]]; then
    echo "Found mounted libvirt-sock, assigning groupid $gid to webvirtmgr"
    groupadd --system --gid "$gid" --non-unique libvirtd
    usermod --append --groups libvirtd webvirtmgr
  fi
fi

echo "Changing ownership of /data to webvirtmgr.nogroup"
chown -R webvirtmgr:nogroup "/data"

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
