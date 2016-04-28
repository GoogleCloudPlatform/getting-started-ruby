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

# TODO test against Ruby 1.9.3

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../../../spec/e2e", __FILE__)
require "rspec/rails"
require "capybara/rails"
require 'capybara/poltergeist'
require "rack/test"

database_config = Rails.application.config.database_configuration[Rails.env]
setupE2EConfig = ENV["E2E_URL"] == nil

if Book.respond_to? :dataset
  require "datastore_book_extensions"
  Book.send :include, DatastoreBookExtensions
  Book.dataset.connection.http_host = database_config["host"]
end

Rails.configuration.x.fog_dir = "testbucket"

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before :each, :e2e => false do
    Book.delete_all
    Fog::Mock.reset
    FogStorage.directories.create key: "testbucket", acl: "public-read"
  end

  config.before :example, :e2e => true do
    if setupE2EConfig
      # Set up database.yml for e2e tests with values from environment variables
      db_file = File.expand_path("../../config/database.yml", __FILE__)
      db_config = File.read(db_file)

      if ENV["GOOGLE_PROJECT_ID"].nil?
        raise "Please set environment variable GOOGLE_PROJECT_ID"
      end
      project_id = ENV["GOOGLE_PROJECT_ID"]

      find = "#   dataset_id: your-project-id"
      replace = "  dataset_id: #{project_id}"
      db_config.sub!(find, replace)

      File.open(db_file, "w") {|file| file.puts db_config }
      setupE2EConfig = false
    end

    # set the backend to datastore
    cmd = "bundle exec rake backend:datastore"
    `#{cmd}`
  end

  config.after :example, :e2e => true do
    cmd = "bundle exec rake backend:active_record"
    `#{cmd}`
  end
end
