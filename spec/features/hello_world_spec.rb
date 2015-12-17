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

# TEST_URL_ROOT is used for blackbox testing
# if nothing is supplied, the test executes locally
domain = ENV["TEST_URL_ROOT"] || ""

feature "Hello World" do

  scenario "saying Hello, World!" do
    visit domain + "/"

    expect(page).to have_content "Hello, world!"
  end

end
