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

class E2E
  class << self
    attr_accessor :configured, :attempted
    alias_method :configured?, :configured
    alias_method :attempted?, :attempted
    def check()
      # this allows the test to be run against a URL specified in an environment
      # variable
      @url ||= ENV["E2E_URL"]
      if @url.nil?
        step_name = ENV["STEP_NAME"]

        if step_name.nil?
          # we are missing arguments to deploy to e2e
          raise "cannot run e2e tests - missing required step_name"
        end

        if attempted?
          # we've tried to run the tests and failed
          raise "cannot run e2e tests - deployment failed"
        end

        @attempted = true
        build_id = ENV["BUILD_ID"]
        deploy(step_name, build_id)
      end

      # use the poltergeist (phantomjs) driver for the test
      Capybara.current_driver = :poltergeist
    end

    def deploy(step_name, build_id = nil)
      build_id ||= rand(1000..9999)

      version = "#{step_name}-#{build_id}"

      # read in our credentials file
      key_path = File.expand_path("../../client_secrets.json", __FILE__)
      key_file = File.read(key_path)
      key_json = JSON.parse(key_file)

      account_name = key_json['client_email'];
      project_id = key_json['project_id'];

      # authenticate with gcloud using our credentials file
      exec "gcloud config set project #{project_id}"
      exec "gcloud config set account #{account_name}"

      # deploy this step_name to gcloud
      # try 3 times in case of intermittent deploy error
      app_yaml_path = File.expand_path("../../#{step_name}/app.yaml", __FILE__)
      for attempt in 0..3
        exec "gcloud app deploy #{app_yaml_path} --version=#{version} -q --no-promote"
        break if $?.to_i == 0
      end

      # if status is not 0, we tried 3 times and failed
      if $?.to_i != 0
        output "Failed to deploy to gcloud"
        return $?.to_i
      end

      # sleeping 1 to ensure URL is callable
      sleep 1

      # run the specs for the step, but use the remote URL
      @url = "https://#{version}-dot-#{project_id}.appspot.com"

      # return 0, no errors
      return 0
    end

    def cleanup()
      # determine build number
      version = @url.match(/https:\/\/(.+)-dot-(.+).appspot.com/)
      unless version
        output "you must pass a build ID or define ENV[\"BUILD_ID\"]"
        return 1
      end

      # run gcloud command
      exec "gcloud app versions delete #{version[1]} -q"

      # return the result of the gcloud delete command
      if $?.to_i != 0
        output "Failed to delete e2e version"
        return $?.to_i
      end

      # return 0, no errors
      return 0
    end

    def deployed?
      not @url.nil?
    end

    def url
      check()
      @url
    end

    def exec(cmd)
      output "> #{cmd}"
      output `#{cmd}`
    end

    def output(line)
      puts line
    end

    def register_config(config)
      config.before :example, :e2e => true do
        unless E2E.configured?
          # Set up database.yml for e2e tests with values from environment variables
          db_file = File.expand_path("../../bookshelf/config/database.yml", __FILE__)
          db_config = File.read(db_file)

          if ENV["GCLOUD_PROJECT"].nil?
            raise "Please set environment variable GCLOUD_PROJECT"
          end
          project_id = ENV["GCLOUD_PROJECT"]

          find = "#   dataset_id: [YOUR_PROJECT_ID]"
          replace = "  dataset_id: #{project_id}"
          db_config.sub!(find, replace)

          File.open(db_file, "w") {|file| file.puts db_config }
          E2E.configured = true
        end

        # set the backend to datastore
        E2E.exec("bundle exec rake backend:datastore")
      end

      config.after :example, :e2e => true do
        E2E.exec("bundle exec rake backend:active_record")
      end
    end

    def register_cleanup(config)
      config.after :suite do
        if E2E.deployed? and ENV["E2E_URL"].nil?
          E2E.cleanup
        end
      end
    end
  end
end
