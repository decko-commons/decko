FROM ethn/decko-base

RUN bundle install
RUN bundle exec rake decko:update_assets_symlink
