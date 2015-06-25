require "sinatra"
require "logger"

get "/" do
  if File.directory? "/var/log/app_engine/custom_logs"
    log = Logger.new("/var/log/app_engine/custom_logs/application.log", File::WRONLY | File::APPEND)
  else
    log = Logger.new(STDERR)
  end
  log.info "YOU REQUESTED SOMETHING! #{Time.now}"
  "hi there @ #{Time.now} DIR? #{File.directory? "/var/log/app_engine/custom_logs"} FILE? #{File.file? "/var/log/app_engine/custom_logs/application.log"}"
end

get "/_ah/health" do
  "ok"
end
