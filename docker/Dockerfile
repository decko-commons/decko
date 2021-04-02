
# "passenger-full" includes passenger, ruby 2.7, nginx, and memcached
# (and more, but those are the things we need)
#
# Could be optimized to use less space
FROM phusion/passenger-full:1.0.12

# ENABLE RUBY, MEMCACHED, NGINX
# use ruby 2.7
RUN bash -lc 'rvm --default use ruby-2.7.2'
# enable memcached
RUN rm -f /etc/service/memcached/down
# enable nginx
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

# add nginx site configuration file
COPY mydeck.conf /etc/nginx/sites-enabled/mydeck.conf

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

WORKDIR /deck

COPY --chown=app:app template/ .

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
