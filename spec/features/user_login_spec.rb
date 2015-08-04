require "spec_helper"

feature "User login" do

  before do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: :google_oauth2,
      uid: "123456",
      info: { name: "Fake User", image: "https://user-profile/image.png" }
    )
  end

  scenario "Logging in" do
    visit root_path
    expect(page).not_to have_content "Fake User"
    expect(page).not_to have_selector "img[src='https://user-profile/image.png']"
    expect(page).not_to have_link "logout"

    click_link "Login"

    expect(page).to have_content "Fake User"
    expect(page).to have_selector "img[src='https://user-profile/image.png']"
    expect(page).to have_link "logout"
  end

  scenario "Logging out" do
    visit root_path
    click_link "Login"

    expect(page).not_to have_link "Login"
    expect(page).to have_content "Fake User"
    expect(page).to have_selector "img[src='https://user-profile/image.png']"
    expect(page).to have_link "logout"

    click_link "logout"

    expect(page).to have_link "Login"
    expect(page).not_to have_content "Fake User"
    expect(page).not_to have_selector "img[src='https://user-profile/image.png']"
    expect(page).not_to have_link "logout"
  end

end
