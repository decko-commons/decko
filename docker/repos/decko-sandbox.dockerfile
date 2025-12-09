FROM deckocommons/decko-bundled

ENV DECKO_DB_ENGINE=sqlite
RUN ./script/db_yml_from_env.rb

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN bundle install
RUN DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec decko setup
RUN chown -R app.app .
