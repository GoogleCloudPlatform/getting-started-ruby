#!/bin/bash

set -e

# [START logging]
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
cat >/etc/google-fluentd/config.d/railsapp.conf << EOF
<source>
  type tail
  format none
  path /opt/app/shared/log/*.log
  pos_file /var/tmp/fluentd.railsapp.pos
  read_from_head true
  tag railsapp
</source>
EOF
service google-fluentd restart &
# [END logging]

# Install dependencies from apt
apt-get update
apt-get install -y git ruby-dev build-essential libxml2-dev zlib1g-dev nginx libmysqlclient-dev libsqlite3-dev redis-server

gem install bundler --no-ri --no-rdoc

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
systemctl enable railsapp.service
systemctl start railsapp.service

cat gce/resqworker.service > /lib/systemd/system/resqworker.service
systemctl enable resqworker.service
systemctl start resqworker.service
