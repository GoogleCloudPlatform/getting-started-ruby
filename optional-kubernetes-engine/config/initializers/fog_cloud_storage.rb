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

if Rails.env.test?

  Fog.mock!
  FogStorage = Fog::Storage.new(
    provider: "Google",
    google_storage_access_key_id: "mock",
    google_storage_secret_access_key: "mock"
  )
  FogStorage.directories.create key: "testbucket", acl: "public-read"
  StorageBucket = FogStorage.directories.get "testbucket"

else

  # [START fog_storage]
  config = Rails.application.config.x.settings["cloud_storage"]

  FogStorage = Fog::Storage.new(
    provider: "Google",
    google_storage_access_key_id:     config["access_key_id"],
    google_storage_secret_access_key: config["secret_access_key"]
  )

  StorageBucket = FogStorage.directories.new key: config["bucket"]
  # [END fog_storage]

end
