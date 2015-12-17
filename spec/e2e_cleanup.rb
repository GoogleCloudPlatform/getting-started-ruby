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

# determine branch name
if ARGV.size < 1
  puts "usage: ruby spec/e2e_cleanup.rb BRANCH_NAME [BUILD_NUM]"
  exit 1
end

branch = ARGV[0]

# determine build number
if ARGV.size < 2 and not ENV['TRAVIS_BUILD_ID']
  puts "you must pass a build number or define ENV[\"TRAVIS_BUILD_ID\"]"
  exit 1
end

build_num = ARGV[1] || ENV['TRAVIS_BUILD_ID']

# run gcloud command
cmd = "gcloud preview app modules delete default --version=#{branch}-#{build_num} -q"
puts "> #{cmd}"
puts `#{cmd}`
