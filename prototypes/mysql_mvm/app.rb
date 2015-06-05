require "mysql2"
require "sequel"
require "yaml"
require "rack"
require "erb"

ENV["RACK_ENV"] ||= "development"

database_config = YAML.load_file("database.yml")[ENV["RACK_ENV"]]

DB = Sequel.connect(database_config)

unless DB.tables.include? :books
  puts "Migrating [books]"
  DB.create_table :books do
    primary_key :id
    String :title
    String :author
  end
end

class App

  def call env
    request = Rack::Request.new env
    response = Rack::Response.new

    case [request.request_method, request.path_info]
    when ["GET", "/"]
      books = DB[:books].all
      template = File.read("index.erb")
      response.headers["Content-Type"] = "text/html"
      response.write ERB.new(template).result(binding)
    when ["POST", "/books"]
      DB[:books].insert title: request.params["title"], author: request.params["author"]
      response.redirect "/"
    when ["DELETE", "/books"]
      DB[:books].where(id: request.params["id"].to_i).delete
      response.redirect "/"
    when ["GET", "/_ah/health"]
      response.write "ok"
    else
      response.status = 404
      response.write "Not found: #{request.request_method} #{request.path_info}"
    end

    response.finish
  end

end
