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

feature "User login (e2e)" do

  scenario "Logging in (e2e)", :e2e => true do
    visit E2E.url + root_path

    click_link "Login"
    expect(page.status_code).to eq 200
    expect(page).to have_content "Sign in with your Google Account"

    uri = URI.parse(current_url)
    query = CGI.parse(uri.query)

    expect(uri.scheme).to eq "https"
    expect(uri.host).to eq "accounts.google.com"
    expect(uri.path).to eq "/ServiceLogin"
    expect(query).to have_key "continue"

    uri = URI.parse(query["continue"][0])
    query = CGI.parse(uri.query)

    expect(uri.scheme).to eq "https"
    expect(uri.host).to eq "accounts.google.com"
    expect(uri.path).to eq "/o/oauth2/auth"
    expect(query).to have_key "redirect_uri"
    expect(query).to have_key "client_id"
    expect(query).to have_key "access_type"
    expect(query).to have_key "response_type"
    expect(query).to have_key "hl"
    expect(query).to have_key "from_login"
    expect(query).to have_key "scope"
    expect(query).to have_key "state"
  end
end
