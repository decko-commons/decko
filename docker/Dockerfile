# Sample Dockerfile for Decko Monkeys

# NOTE: the main intended use for this Dockerfile template is for creating images
# for sharing or deploying.

# During normal development, you probably won't want to do lots of docker builds. Instead,
# the emerging best practice is to use bind mounts so that you can work on your code in
# the host context and still run it when needed in the container context.

# Similarly, in a development context, we don't want to have to go through a docker build
# every time we tweak a Gemfile, and we certainly want gems to persist when we start
# and stop containers, so we recommend using named volumes for gems while developing.
# (see comments in sample docker-compose.yml).

FROM ethn/decko-base

WORKDIR /deck

# Assumes Dockerfile is in the root directory of your deck
COPY . .

# Depending on your use case, you may or may not want gems pre-installed inside your
# docker image.  Only use `bundle install` if you do.
RUN bundle install

# Use baseimage-docker's init process. (see passenger-docker to learn more)
CMD ["/sbin/my_init"]
