#FROM dl.tcpdrop.com:5000/archlinux
#RUN pacman --noconfim -y
#RUN pacman --noconfim -S nginx python-pip
FROM ubuntu:trusty
MAINTAINER Tim Sogard <docker@timsogard.com>

ADD conf/ /opt/graphite/_docker_conf/

# Install nginx, supervisor
RUN apt-get update
RUN apt-get install nginx python-dev python-pip python-cairo supervisor -y

# Install graphite
RUN pip install uwsgi
RUN pip install 'django<1.6' django-tagging
RUN pip install https://github.com/graphite-project/ceres/tarball/master
RUN pip install whisper
RUN pip install carbon
RUN pip install graphite-web

# "Fix" for "cannot import name daemonize"
RUN pip install 'Twisted<12.0'

# Add user, configure carbon-cache, graphite-web, nginx, uwsgi
RUN useradd -m -s /bin/bash graphite
RUN cp /opt/graphite/_docker_conf/supervisor/graphite.conf /etc/supervisor/conf.d/graphite.conf
RUN cp /opt/graphite/_docker_conf/graphite/* /opt/graphite/conf/
RUN cp /opt/graphite/_docker_conf/graphite-web/* /opt/graphite/webapp/graphite/
RUN cp /opt/graphite/_docker_conf/nginx/* /etc/nginx/sites-enabled/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Build initial database
RUN cd /opt/graphite/conf && python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

# Perms
RUN chown -R graphite:graphite /opt/graphite/storage

# Setup server
WORKDIR /opt/graphite/
USER graphite
EXPOSE 80 2003

CMD /usr/bin/supervisord
