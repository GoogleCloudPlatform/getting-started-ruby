require 'rack'
require 'fog'

class HelloWorldApp
  def self.call(env)
    storage = Fog::Storage.new(
      :provider => 'Google',
      :google_storage_access_key_id => 'id here',
      :google_storage_secret_access_key => 'key here'
    )

    request = Rack::Request.new env
    response = Rack::Response.new

    if request.params['message']
      response.write "Hello #{request.params['message']}"
    else
      response.write 'Hello World'
    end
    response.write '<br>'

    storage.directories.each do |dir|
      response.write dir.key
      response.write '<br>'
      dir.files.each do |file|
        response.write file.key
        response.write '<br>'
      end
    end

    response.status = 200
    response.finish
  end
end
