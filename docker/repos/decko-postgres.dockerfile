FROM ethn/decko-bundled

ENV DECKO_DB_ENGINE=postgres
COPY ./template/script/db_yml_from_env.rb script/db_yml_from_env.rb
COPY ./template/config/database.yml.erb config/database.yml.erb

RUN ./script/db_yml_from_env.rb

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN bundle install

