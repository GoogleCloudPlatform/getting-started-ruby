require "sinatra"

get "/" do
  "Hello, world!"
end

get "/_ah/health" do
  "ok"
end
