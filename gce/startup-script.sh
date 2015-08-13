#!/bin/bash

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

set -e

# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")

# Get the source code
export HOME=/root
git config --global credential.helper gcloud.sh
# Change branch from master if not using master
git clone https://source.developers.google.com/p/$PROJECTID /opt/app -b master

pushd /opt/app

pushd config

cp database.example.yml database.yml
chmod go-rwx database.yml
cp cloud_storage.example.yml cloud_storage.yml
chmod go-rwx cloud_storage.yml

chmod go-rwx secrets.yml

# Add your database config here
sed -i -e 's/@@USER@@/your-cloud-sql-username/' database.yml
sed -i -e 's/@@PASS@@/your-cloud-sql-password/' database.yml
sed -i -e 's/@@IP@@/your-cloud-sql-ip/' database.yml
sed -i -e 's/@@DB@@/your-cloud-sql-db-name/' database.yml

# Add your cloud storage config here
sed -i -e 's/@@BUCKET@@/your-cloud-storage-bucket/' cloud_storage.yml
sed -i -e 's/@@ID@@/your-access-key-id/' cloud_storage.yml
sed -i -e 's:@@KEY@@:your-secret-access-key:' cloud_storage.yml

# Add your OAuth config here
sed -i -e 's/@@ID@@/your-oauth-client-id/' secrets.yml
sed -i -e 's/@@SECRET@@/your-oauth-client-secret/' secrets.yml

popd # config

./gce/configure.sh

popd # /opt/app
