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

require File.expand_path("../boot", __FILE__)

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bookshelf
  class Application < Rails::Application
    # Load settings.yml
    config.x.settings = Rails.application.config_for :settings

    # Choose database backend based on configuration in settings.yml
    Rails.application.config.x.database = ActiveSupport::StringInquirer.new(
      Rails.application.config.x.settings["database"]
    )

    # Enable ActiveRecord when using SQL database (Cloud SQL or Postgresql)
    if Rails.application.config.x.database.sql?
      require "active_record/railtie"
    end
  end
end
