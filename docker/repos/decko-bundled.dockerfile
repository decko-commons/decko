FROM ethn/decko-base

ENV DECKO_DB_ENGINE=all

RUN bundle install
RUN bundle exec rake decko:update_assets_symlink
