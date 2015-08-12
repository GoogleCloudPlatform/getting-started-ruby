#! /bin/bash

# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")

# Get the source code
git config --global credential.helper gcloud.sh
# Change branch from master if not using master
git clone https://source.developers.google.com/p/$PROJECTID /opt/app -b master

pushd /opt/app

pushd config

cp database.example.yml database.yml
cp cloud_storage.example.yml cloud_storage.yml

# Add your database config here
sed -i 's/your-mysql-user-here/railsapp/' database.yml
sed -i 's/your-mysql-password-here/password/' database.yml
sed -i 's/your-mysql-IPv4-address-here/1.2.3.4/' database.yml
sed -i 's/your-mysql-database-here/library/' database.yml

# Add your cloud storage config here
sed -i 's/your-bucket-name/mybucket/' cloud_storage.yml
sed -i 's/your-access-key-id/1234/' cloud_storage.yml
sed -i 's/your-secret-access-key/1234/' cloud_storage.yml

# Add your OAuth config here
sed -i 's/<client ID>/1234/' secrets.yml
sed -i 's/<client secret>/1234/' secrets.yml

popd # config

./startup-in-git.sh

popd # /opt/app
