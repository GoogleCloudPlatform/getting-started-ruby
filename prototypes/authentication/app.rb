require "omniauth"
require "omniauth-google-oauth2"
require "sinatra"
require "slim"
require "ostruct"

ENV["RACK_ENV"] ||= "development"

# Detect HTTPS header on App Engine so OAuth origin is set correctly.
# Note: could also set request.env["omniauth.origin"] manually to an absolute URI
class AppEngineHttps
  def initialize app
    @app = app
  end

  def call env
    if env["HTTP_X_APPENGINE_HTTPS"] == "on"
      env["rack.url_scheme"] = "https"
      env["SERVER_PORT"] = 443
    end
    @app.call env
  end
end

configure do
  enable :sessions
  set :session_secret, "<session secret for cookie signing>"

  use AppEngineHttps

  auth_config = YAML.load_file("authentication.yml")[ENV["RACK_ENV"]]

  use OmniAuth::Builder do
    provider :google_oauth2, auth_config["client_id"], auth_config["client_secret"], image_size: 150
  end
end

get "/" do
  @user = session[:user]
  slim :index
end

get "/login" do
  redirect "/auth/google_oauth2"
end

get "/logout" do
  session.clear
  redirect "/"
end

get "/auth/google_oauth2/callback" do
  auth = request.env["omniauth.auth"]
  session[:user] = OpenStruct.new(
    id: auth["uid"],
    name: auth["info"]["name"],
    image: auth["info"]["image"]
  )
  redirect "/"
end

get "/auth/failure" do
  "Login failed (#{params[:message]})"
end

get "/_ah/health" do
  "ok"
end

__END__

@@ index
doctype html
html
  head
    title Ruby Google Authentication Example
    css:
      @import url(//fonts.googleapis.com/css?family=Abril+Fatface);

      body {
        padding-top: 30px;
        text-align: center;
        font-size: 50px;
        font-family: 'Abril Fatface', cursive;
      }
      a {
        text-decoration: none;
      }
      img {
        display: block;
        margin: 0 auto;
      }
  body
    - if @user
      p Hello #{@user.name}!
      img src=@user.image
      a href="/logout" Logout
    - else
      a href="/login" Login
