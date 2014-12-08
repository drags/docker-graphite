FROM ubuntu:trusty
MAINTAINER Tim Sogard <docker@timsogard.com>

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

# Add user
RUN groupadd -g 2001 graphite
RUN useradd -m -s /bin/bash -u 2001 -g graphite graphite

# Configure carbon-cache, graphite-web, nginx, uwsgi
ADD conf/ /opt/graphite/_docker_conf/
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
USER root
EXPOSE 80 2003 2004

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
