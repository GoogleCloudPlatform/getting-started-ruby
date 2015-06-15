require "logger"

ENV["RACK_ENV"] ||= "development"

if ENV["RACK_ENV"] == "production"
  logger = Logger.new("/var/log/app_engine/custom_logs/application.log", File::WRONLY | File::APPEND)
else
  logger = Logger.new(STDOUT)
end

run -> (env) {
  logger.info "Received request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
  [200, {"Content-Type" => "text/plain"}, ["[#{Time.now}] Hello!"]]
}
