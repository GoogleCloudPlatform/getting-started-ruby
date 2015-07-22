require "sinatra"

get "/" do
  "Hello World"
end

get "/render-something" do
  erb :something
end

get "/_ah/health" do
  "ok"
end
