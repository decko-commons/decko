FROM deckocommons/decko-base

RUN bundle install
RUN rake card:mod:symlink

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN chown -R app.app .
