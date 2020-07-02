#!/bin/bash -x

set -o errexit    # exit on error
set -o pipefail   # exit on error in pipe

if [[ ! -f "/data/webvirtmgr.sqlite3" ]]; then
  /usr/bin/python /webvirtmgr/manage.py syncdb --noinput
  echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', '1234')" | /usr/bin/python /webvirtmgr/manage.py shell
fi

supervisorctl start webvirtmgr
supervisorctl start webvirtmgr-console
