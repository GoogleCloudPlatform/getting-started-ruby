require "rspec"
require "rack"
require "rack/test"

RSpec.describe "Hello world app" do
  include Rack::Test::Methods

  def app
    app, options = Rack::Builder.parse_file "config.ru"
    app
  end

  it "should respond" do
    get "/"

    expect(last_response.status).to eq 200
    expect(last_response.headers["Content-Type"]).to eq "text/plain"
    expect(last_response.body).to match %r{The time is currently \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [\+-]\d{4}}
  end

end
