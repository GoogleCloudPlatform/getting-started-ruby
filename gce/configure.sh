#!/bin/bash

# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START all]
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
apt-get install -y git ruby ruby-dev build-essential libxml2-dev zlib1g-dev nginx libmysqlclient-dev libsqlite3-dev redis-server

gem install bundler --no-ri --no-rdoc

useradd -m railsapp
chown -R railsapp:railsapp /opt/app

mkdir /opt/gem
chown -R railsapp:railsapp /opt/gem

sudo -u railsapp -H bundle install --path /opt/gem
sudo -u railsapp -H bundle exec rake db:create
sudo -u railsapp -H bundle exec rake db:migrate

systemctl enable redis-server.service
systemctl start redis-server.service

cat gce/default-nginx > /etc/nginx/sites-available/default
systemctl restart nginx.service

cat gce/railsapp.service > /lib/systemd/system/railsapp.service
systemctl enable railsapp.service
systemctl start railsapp.service

cat gce/resqworker.service > /lib/systemd/system/resqworker.service
systemctl enable resqworker.service
systemctl start resqworker.service
# [END all]
