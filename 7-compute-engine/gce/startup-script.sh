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

# [START all]
set -e

# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
REPO_NAME="[YOUR_REPO_NAME]"

# Get the source code
export HOME=/root
git config --global credential.helper gcloud.sh
# Change branch from master if not using master
git clone https://source.developers.google.com/p/$PROJECTID/r/$REPO_NAME /opt/app -b master

pushd /opt/app/7-compute-engine

pushd config

cp database.example.yml database.yml
chmod go-rwx database.yml
cp settings.example.yml settings.yml
chmod go-rwx settings.yml

# [START config]
# Add your GCP project ID here
sed -i -e 's/@@PROJECT_ID@@/[YOUR_PROJECT_ID]/' settings.yml
sed -i -e 's/@@PROJECT_ID@@/[YOUR_PROJECT_ID]/' database.yml

# Add your cloud storage config here
sed -i -e 's/@@BUCKET_NAME@@/[YOUR_BUCKET_NAME]/' settings.yml

# Add your OAuth config here
sed -i -e 's/@@CLIENT_ID@@/[YOUR_CLIENT_ID]/' settings.yml
sed -i -e 's/@@CLIENT_SECRET@@/[YOUR_CLIENT_SECRET]/' settings.yml
# [END config]
popd # config

./gce/configure.sh

popd # /opt/app
# [END all]
