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

require 'json'

def puts_and_exec(cmd)
  puts "> #{cmd}"
  puts `#{cmd}`
end

if ARGV.size < 1
  puts "usage: ruby spec/e2e.rb [branch-name]"
  exit 1
end

branch = ARGV[0]
build_num = ENV['TRAVIS_BUILD_NUM'] || rand(1000..9999)
version = "#{branch}-#{build_num}"

# read in our credentials file
key_file = File.read(File.expand_path("../../client_secrets.json", __FILE__))
key_json = JSON.parse(key_file)

account_name = key_json['client_email'];
project_id = key_json['project_id'];

# authenticate with gcloud using our credentials file
puts_and_exec("gcloud auth activate-service-account --key-file client_secrets.json")
puts_and_exec("gcloud config set project #{project_id}")
puts_and_exec("gcloud config set account #{account_name}")

# deploy this branch to gcloud
# try 3 times in case of intermittent deploy error
for attempt in 0..3
  puts_and_exec("gcloud preview app deploy app.yaml --version=#{version} -q")
  break if $?.to_i == 0
end

# if status is not 0, we tried 3 times and failed
if $?.to_i != 0
  puts "Failed to deploy to gcloud"
  exit $?.to_i
end

# # run the specs for the branch, but use the remote URL
url = "https://#{version}-dot-#{project_id}.appspot.com"
puts_and_exec("TEST_URL_ROOT=#{url} bundle exec rspec spec")

if $?.to_i != 0
  puts "tests failed for #{branch}"
  exit $?.to_i
end

puts "e2e tests successful!"
