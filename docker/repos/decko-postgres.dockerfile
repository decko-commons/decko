FROM deckocommons/decko-bundled

ENV DECKO_DB_ENGINE=postgres
RUN ./script/db_yml_from_env.rb

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN bundle install

