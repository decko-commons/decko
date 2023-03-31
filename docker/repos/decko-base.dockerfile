# PASSENGER-DOCKER
# https://github.com/phusion/passenger-docker
FROM phusion/passenger-full

# ENABLE RUBY, MEMCACHED, NGINX
# use ruby 2.7 (default)
RUN bash -lc 'rvm --default use ruby-2.7.7'
# enable memcached
RUN rm -f /etc/service/memcached/down
# enable nginx
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# INSTALL IMAGEMAGICK
RUN apt-get update -y
RUN apt-get install -y imagemagick

# NGINX CONFIG
COPY mydeck.conf /etc/nginx/sites-enabled/mydeck.conf

WORKDIR /deck

COPY --chown=app:app template/ .
COPY bundle_config .bundle/config
RUN gem update bundler

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
