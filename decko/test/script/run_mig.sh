#!/bin/bash

VER=1.15.pre
DBCFG=../database.yml.local
SEEDSQL=../mdummy_test.sql
cd decko/
gem build decko.gemspec
mv *.gem ../card/
cd ../decko-rails
gem build decko.gemspec
mv *.gem ../card/
cd ../card
gem build card.gemspec
gem install *-${VER}.gem
cd ../test_work
rbenv which decko
echo Generate a decko app
decko new test_decko_app -c --gem-path='../../'
cd test_decko_app
# load seed db (customize to your database.yml)
echo "Load seed db (enter the pw)"
mysql -u decko_user -p mdummy_test < ${SEEDSQL}
# copy db config (populate .local with you user/pw)
cp ${DBCFG} config/database.yml
echo "migrating"
#RAILS_ENV=test bundle exec rake db:migrate --trace
RAILS_ENV=test bundle exec rake decko:migrate --trace
#RAILS_ENV=development bundle exec rake db:migrate --trace
#RAILS_ENV=development bundle exec rake decko:migrate --trace
