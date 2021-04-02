
# "passenger-full" includes passenger, ruby 2.7, nginx, and memcached
# (and more, but those are the things we need)
FROM phusion/passenger-full:1.0.12

# user ruby 2.7
RUN bash -lc 'rvm --default use ruby-2.7.2'

# enable memcached
RUN rm -f /etc/service/memcached/down

# enable nginx
RUN rm /etc/nginx/sites-enabled/default

# add nginx site configuration file
COPY files/mydeck.conf /etc/nginx/sites-enabled/mydeck.conf

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

WORKDIR /deck

# normally bad practice to run bundle as root, but it's ok in a container
RUN bundle config silence_root_warning 1

# enforce consistency between Gemfile and Gemfile.lock
RUN bundle config set deployment 'true'

# installing outside of working path makes it easier to make use of docker caching
RUN bundle config path '/vendor'

COPY template/Gemfile* .
RUN bundle install
COPY --chown=app:app template/ .


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
