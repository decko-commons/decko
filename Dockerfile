FROM phusion/passenger-ruby27
MAINTAINER Gerry Gleason (gerryg@inbox.com)

WORKDIR /work
COPY docker/files/* /tmp/build/
RUN /tmp/build/setup.sh

