import os

LOCAL_PATH = '/data'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(LOCAL_PATH, 'webvirtmgr.sqlite3'),
    }
}

MEDIA_ROOT = os.path.join(LOCAL_PATH, 'media')
