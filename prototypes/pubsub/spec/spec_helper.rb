ENV["RACK_ENV"] = "test"

require_relative "../app"

require "rspec"
require "capybara/rspec"
require "mock_pub_sub"

Capybara.app = Sinatra::Application
