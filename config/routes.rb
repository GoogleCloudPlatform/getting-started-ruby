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

Rails.application.routes.draw do

  # [START health_checks]
  get "_ah/health", to: "app_engine#health"
  # [END health_checks]

  get "_ah/start", to: "app_engine#start"
  get "_ah/stop", to: "app_engine#stop"

  # [START default_route]
  root "hello#index"
  # [END default_route]

end
