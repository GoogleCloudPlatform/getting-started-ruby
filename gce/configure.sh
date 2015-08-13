#!/bin/bash

set -e

# # Install logging monitor and configure it to pickup application logs
# # [START logging]
# curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash

# cat >/etc/google-fluentd/config.d/pythonapp.conf << EOF
# <source>
#   type tail
#   format json
#   path /opt/app/general.log
#   pos_file /var/tmp/fluentd.pythonapp-general.pos
#   tag pythonapp-general
# </source>
# EOF

# service google-fluentd restart &
# # [END logging]

# Install dependencies from apt
apt-get update
apt-get install -y git ruby-dev build-essential libxml2-dev zlib1g-dev nginx libmysqlclient-dev libsqlite3-dev
# redis-server

gem install rails bundler --no-ri --no-rdoc

# # Create a pythonapp user. The application will run as this user.
useradd -m railsapp
chown -R railsapp:railsapp /opt/app

mkdir /opt/gem
chown -R railsapp:railsapp /opt/gem

sudo -u railsapp -H bundle install --path /opt/gem
sudo -u railsapp -H bundle exec rake db:create
sudo -u railsapp -H bundle exec rake db:migrate

cat gce/default-nginx > /etc/nginx/sites-available/default
systemctl restart nginx.service

cat gce/railsapp.service > /lib/systemd/system/railsapp.service
systemctl daemon-reload
systemctl enable railsapp.service
systemctl start railsapp.service
