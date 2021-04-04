# PASSENGER-DOCKER
# https://github.com/phusion/passenger-docker
FROM phusion/passenger-customizable

# use ruby 2.7
RUN /pd_build/ruby-2.7.*.sh
# enable memcached
RUN /pd_build/memcached.sh
RUN rm -f /etc/service/memcached/down
# enable nginx
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
# enable nodejs (for javascript runtime)
RUN /pd_build/nodejs.sh

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

ARG DECKO_FILE_STORAGE
ENV DECKO_FILE_STORAGE=${DECKO_FILE_STORAGE}

RUN bundle install
RUN bundle exec rake decko:update_assets_symlink

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
