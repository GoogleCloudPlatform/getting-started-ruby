require_relative "app"

use Rack::MethodOverride

run App.new
