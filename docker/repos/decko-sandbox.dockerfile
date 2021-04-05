FROM ethn/decko-bundled

ENV DECKO_DB_ENGINE=sqlite

RUN erb config/database.yml.erb > config/database.yml

RUN bundle install

RUN decko seed
