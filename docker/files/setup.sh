
su - app sh -c 'cd /home/app/; tar -xzvf /tmp/build/deckoapp.tgz'
apt-get update -y
apt-get install -y ruby-dalli

cd /work
cp /home/app/deckoapp/Gemfile .
ls -l
pwd
bundle install

# turn off captcha gem
cp /tmp/build/Modfile /usr/local/rvm/gems/ruby-2.7.1/gems/card-1.99.6/mod/Modfile
mv /tmp/build/env.conf /etc/nginx/main.d/env.conf
mv /tmp/build/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil.key
chmod 400 /etc/ssl/private/ssl-cert-snakeoil.key
mv /tmp/build/ssl-cert-snakeoil.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
rm /etc/nginx/sites-enabled/default
mv /tmp/build/webapp.conf /etc/nginx/sites-enabled/webapp.conf
rm /etc/service/nginx/down
