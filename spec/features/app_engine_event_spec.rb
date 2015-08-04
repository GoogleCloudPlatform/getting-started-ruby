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

require "spec_helper"

feature "Handling App Engine events" do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  scenario "responding to health checks" do
    get "/_ah/health"

    expect(last_response.status).to eq 200
    expect(last_response.body).not_to be_empty
  end

end
