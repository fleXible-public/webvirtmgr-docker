import os

DATABASES = {
    'LOCAL_PATH': '/data/vm',
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/data/vm/webvirtmgr.sqlite3',
    },
}


