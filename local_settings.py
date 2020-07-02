import os

DATABASES = {
    'LOCAL_PATH': '/data',
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/data/webvirtmgr.sqlite3',
    }
}


