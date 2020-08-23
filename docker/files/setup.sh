
su - app sh -c 'cd /home/app/; tar -xzvf /tmp/build/deckoapp.tgz'

cd /work
cp /home/app/deckoapp/Gemfile .
ls -l
pwd
bundle install

mv /tmp/build/env.conf /etc/nginx/main.d/env.conf
rm /etc/nginx/sites-enabled/default
mv /tmp/build/webapp.conf /etc/nginx/sites-enabled/webapp.conf
rm /etc/service/nginx/down
