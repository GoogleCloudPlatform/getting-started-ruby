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

if [ $# -ne 1 ]; then
    echo $0: usage: setup.sh STEP_NAME
    exit 1
fi

STEP_NAME=$1

TEST_DIR=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )/../$STEP_NAME

# copy example settings config to settings.yml
if [ -f $TEST_DIR/config/settings.example.yml ]; then
  cp $TEST_DIR/config/settings.example.yml $TEST_DIR/config/settings.yml
  if [ -n "$GOOGLE_CLIENT_ID" ]; then
    sed -i -e "s/[YOUR_CLIENT_ID]/$GOOGLE_CLIENT_ID/g" $TEST_DIR/config/settings.yml
  fi

  if [ -n "$GOOGLE_CLIENT_SECRET" ]; then
    sed -i -e "s/[YOUR_CLIENT_SECRET]/$GOOGLE_CLIENT_SECRET/g" $TEST_DIR/config/settings.yml
  fi

  if [ -n "$GOOGLE_PROJECT_ID" ]; then
    sed -i -e "s/[YOUR_PROJECT_ID]/$GOOGLE_PROJECT_ID/g" $TEST_DIR/config/settings.yml
  fi
fi

# copy example database config to database.yml
if [ -f $TEST_DIR/config/database.example.yml ]; then
  cp $TEST_DIR/config/database.example.yml $TEST_DIR/config/database.yml
  if [ -n "$GOOGLE_PROJECT_ID" ]; then
    sed -i -e "s/[YOUR_PROJECT_ID]/$GOOGLE_PROJECT_ID/g" $TEST_DIR/config/database.yml
  fi
fi

if [ "$STEP_NAME" = '2-cloud-datastore' -o "$STEP_NAME" = 'optional-kubernetes-engine' ]; then
  # download cloud-datastore-emulator testing tool
  wget -q https://storage.googleapis.com/gcd/tools/cloud-datastore-emulator-1.1.1.zip -O cloud-datastore-emulator.zip
  unzip -o cloud-datastore-emulator.zip

  # start cloud-datastore-emulator test server
  cloud-datastore-emulator/cloud_datastore_emulator create gcd-test-dataset-directory
  cloud-datastore-emulator/cloud_datastore_emulator start --testing ./gcd-test-dataset-directory/ &
fi

if [ "$STEP_NAME" = '7-compute-engine' ]; then
  if [ -n "$GOOGLE_CLIENT_ID" ]; then
    sed -i -e "s/CLIENT_ID/$GOOGLE_CLIENT_ID/g" $TEST_DIR/config/settings.yml
  fi

  if [ -n "$GOOGLE_CLIENT_SECRET" ]; then
    sed -i -e "s/YOUR_CLIENT/$GOOGLE_CLIENT_SECRET/g" $TEST_DIR/config/settings.yml
  fi

  if [ -n "$GOOGLE_PROJECT_ID" ]; then
    sed -i -e "s/PROJECT_ID/$GOOGLE_PROJECT_ID/g" $TEST_DIR/config/settings.yml
    sed -i -e "s/PROJECT_ID/$GOOGLE_PROJECT_ID/g" $TEST_DIR/config/database.yml
  fi
fi

# compile assets if an "assets" directory exists
if [ -e $TEST_DIR/app/assets ]; then
  RAILS_ENV=test bundle exec rake --rakefile=$TEST_DIR/Rakefile assets:precompile
fi

# run rake DB tasks after all other changes
if [ -d $TEST_DIR/db/migrate -a "$STEP_NAME" != 'optional-kubernetes-engine' ]; then
  # create the tables required for testing
  RAILS_ENV=test bundle exec rake --rakefile=$TEST_DIR/Rakefile db:migrate
fi
