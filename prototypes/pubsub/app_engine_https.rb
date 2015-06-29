# Detect HTTPS header on App Engine
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
