ENV["RACK_ENV"] = "test"

require_relative "app"

require "rspec"
require "capybara/rspec"

Capybara.app = Sinatra::Application

OmniAuth.config.test_mode = true

RSpec.describe "Application with user login" do
  include Capybara::DSL

  before do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: :google_oauth2,
      uid: "123456",
      info: {
        name: "Fake User",
        image: "https://user-profile/image.png"
      }
    )
  end

  it "can successfully login" do
    visit "/"
    expect(page).to have_link "Login"
    expect(page).not_to have_link "Logout"
    expect(page).not_to have_content "Hello Fake User!"

    click_link "Login"

    expect(page).not_to have_link "Login"
    expect(page).to have_content "Hello Fake User!"
  end

  it "can logout" do
    visit "/"
    click_link "Login"
    expect(page).not_to have_link "Login"
    expect(page).to have_content "Hello Fake User!"

    click_link "Logout"

    expect(page).to have_link "Login"
    expect(page).not_to have_content "Hello Fake User!"
  end

  it "can fail to login" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    visit "/"
    click_link "Login"

    expect(page).to have_content "Login failed"
  end

end
