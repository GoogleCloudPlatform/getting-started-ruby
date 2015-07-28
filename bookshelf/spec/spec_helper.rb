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

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "capybara/rails"
require "rack/test"

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:all) do
    Fog.mock!
    Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')
    storage = Fog::Storage.new(
      :provider => 'Google',
    )
    if storage.directories.get(Rails.configuration.x.fog_dir).nil?
      storage.directories.create(key: Rails.configuration.x.fog_dir, acl: "public-read")
    end
  end

end
