# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
