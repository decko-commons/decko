FROM deckocommons/decko-bundled

ENV DECKO_DB_ENGINE=sqlite
COPY mydeck.conf /etc/nginx/sites-enabled/mydeck.conf
RUN ./script/db_yml_from_env.rb

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN gem install bundler --force -N -v "$(tail -n 1 Gemfile.lock | tr -d '[:blank:]\n')" && bundle --version
    # Fix for issue with bundler
    # see https://github.com/phusion/passenger-docker/issues/409
    # and https://stackoverflow.com/questions/78747131/app-not-starting-with-cryptic-passenger-log-error
RUN bundle install
RUN DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec decko setup
RUN chown -R app.app .
