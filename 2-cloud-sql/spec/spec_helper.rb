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
require File.expand_path("../../../spec/e2e", __FILE__)
require "rspec/rails"
require "capybara/rails"
require "capybara/poltergeist"
require "rack/test"

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:example, :e2e) do
    unless E2E.configured?
      # Set up database.yml for e2e tests with values from environment variables
      db_file = File.expand_path("../../config/database.yml", __FILE__)
      db_config = File.read(db_file)
      db_values = {
        "your-mysql-user-here" => "MYSQL_USER",
        "your-mysql-password-here" =>  "MYSQL_PASSWORD",
        "your-mysql-IPv4-address-here" => "MYSQL_HOST",
        "your-mysql-database-here" => "MYSQL_DBNAME"
      }

      db_values.each { |key, envkey|
        if ENV[envkey].nil?
          raise "Please set environment variable #{envkey}"
        end
        db_config.sub!(key, ENV[envkey])
      }

      File.open(db_file, "w") {|file| file.puts db_config }
      E2E.configured = true
    end
  end

  E2E.register_cleanup(config)
end
