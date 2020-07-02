FROM ubuntu:16.04
MAINTAINER Primiano Tucci <p.tucci@gmail.com>

# Env
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV TZ Europe/Berlin

# Install dependencies
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    git \
    python-pip \
    python-libvirt \
    python-libxml2 \
    supervisor \
    novnc \
  ; \
  apt-get upgrade -y; \
  apt-get clean;

# Install webvirtmgr
RUN git clone https://github.com/retspen/webvirtmgr /webvirtmgr
WORKDIR /webvirtmgr
RUN git checkout 7f140f99f4 #v4.8.8
RUN \
  pip install --upgrade pip && \
  pip install setuptools wheel && \
  pip install -r requirements.txt
ADD local_settings.py /webvirtmgr/webvirtmgr/local/local_settings.py
RUN sed -i 's/0.0.0.0/172.17.42.1/g' vrtManager/create.py
RUN /usr/bin/python /webvirtmgr/manage.py collectstatic --noinput

ADD supervisor.webvirtmgr.conf /etc/supervisor/conf.d/webvirtmgr.conf
ADD gunicorn.conf.py /webvirtmgr/conf/gunicorn.conf.py

ADD bootstrap.sh /webvirtmgr/bootstrap.sh

RUN groupadd webvirtmgr -g 1010
RUN useradd webvirtmgr -g webvirtmgr -u 1010 -d /data -s /sbin/nologin
# RUN useradd webvirtmgr -g libvirtd -u 1010 -d /data -s /sbin/nologin
RUN chown webvirtmgr:webvirtmgr -R /webvirtmgr

WORKDIR /
VOLUME /data/vm

EXPOSE 8080
EXPOSE 6080
CMD ["supervisord", "-n"]
