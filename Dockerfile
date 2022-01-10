# ubuntu bionic LTS version
FROM ubuntu:18.04 AS builder-image

ENV DEBIAN_FRONTEND="noninteractive" \
  PIP_NO_PYTHON_VERSION_WARNING=1 \
  PIP_NO_CACHE_DIR=false \
  PIP_NO_COMPILE=false \
  PIP_QUIET=0 \
  VIRTUALENV_OVERRIDE_APP_DATA='/tmp/virtualenv'

# Install dependencies
RUN apt-get update && \
  apt-get upgrade -qy && \
  apt-get install -qqy --no-install-recommends --no-install-suggests \
    gzip \
    tar \
    python-pip \
    python-setuptools \
    python-wheel \
    wget && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

RUN python -m pip install -U pip && \
  pip install virtualenv

WORKDIR /webvirtmgr

# Create and activate virtual environment
RUN virtualenv -q --system-site-packages --no-periodic-update venv
ENV PATH="/webvirtmgr/venv/bin:$PATH"

# Install webvirtmgr
ADD local_settings.py ./webvirtmgr/local/local_settings.py
RUN wget -q https://github.com/retspen/webvirtmgr/releases/download/v4.8.9/webvirtmgr.tar.gz -O /tmp/webvirtmgr.tar.gz && \
  tar --strip-components=1 -xzf /tmp/webvirtmgr.tar.gz && \
  sed -i 's/django==1.5.5/django==1.5.6/g' requirements.txt && \
  sed -i 's/gunicorn==19.5.0/gunicorn==19.10.0/g' requirements.txt && \
  pip install -r requirements.txt

RUN sed -i 's/0.0.0.0/127.0.0.1/g' vrtManager/create.py && \
  sed -i 's/127.0.0.1:8000/0.0.0.0:8080/g' conf/gunicorn.conf.py && \
  sed -i 's|tmp_upload_dir = None|worker_tmp_dir = "/dev/shm"|g' conf/gunicorn.conf.py && \
  mkdir -p /data && \
  ./manage.py collectstatic --noinput && \
  ./manage.py syncdb --noinput

COPY --from=snyk/snyk:linux /usr/local/bin/snyk /usr/local/bin/snyk


FROM ubuntu:18.04 AS runner-image

ENV DEBIAN_FRONTEND="noninteractive" TERM="linux" TZ="Europe/Berlin" \
  PYTHONUNBUFFERED=1

# Install dependencies
RUN apt-get update && \
  apt-get upgrade -qy && \
  apt-get install -qqy --no-install-recommends --no-install-suggests \
    openssh-client \
    python-libvirt \
    python-libxml2 \
    supervisor \
    novnc && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

# Configure supervisord and bootstrap
ADD supervisor.webvirtmgr.conf /etc/supervisor/conf.d/webvirtmgr.conf
ADD bootstrap.sh /bootstrap.sh

# Create user
RUN useradd webvirtmgr -u 1010 -g nogroup -d /data -s /sbin/nologin

# Pull prepared webvirtmgr installation and activate virtual environment
COPY --from=builder-image --chown=webvirtmgr:nogroup /webvirtmgr /webvirtmgr
ENV PATH="/webvirtmgr/venv/bin:$PATH" VIRTUAL_ENV="/webvirtmgr/venv"

COPY --from=builder-image --chown=webvirtmgr:nogroup /data /data

WORKDIR /data
VOLUME /data

EXPOSE 8080
EXPOSE 6080

CMD ["/bootstrap.sh"]
