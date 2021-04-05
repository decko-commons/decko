FROM ethn/decko-base

RUN bundle install
RUN rake decko:update_assets_symlink

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]
