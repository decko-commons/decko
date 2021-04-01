FROM phusion/passenger-full
RUN bash -lc 'rvm --default use ruby-2.7.2'

RUN bundle config --global silence_root_warning 1

WORKDIR /deck
COPY template/* .

RUN bundle install
