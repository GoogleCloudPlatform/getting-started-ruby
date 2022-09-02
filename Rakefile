require "json"
require "rake"
require "open3"
require "timeout"

task :test do
  run_tests local: true
end

task :acceptance do
  run_tests local: true, acceptance: true
end

namespace :kokoro do
  task :presubmit do
    run_tests
  end

  task :continuous do
    run_tests
  end

  task :post do
    require_relative "rakelib/link_checker.rb"

    link_checker = LinkChecker.new
    link_checker.run
    exit link_checker.exit_status
  end
end

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
end

def header_2 str, token = "#"
  puts "\n#{token * 3} #{str} #{token * 3}\n"
end

def each_sample
  gemfiles = Dir.glob("**/Gemfile") - ["Gemfile"]
  gemfiles.map! { |gemfile| File.dirname gemfile }.uniq!
  gemfiles.each do |dir|
    yield dir
  end
end

def load_env_vars
  service_account = "#{ENV['KOKORO_GFILE_DIR']}/service-account.json"
  raise "#{service_account} is not a file" unless File.file? service_account
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = service_account
  filename = "#{ENV['KOKORO_GFILE_DIR']}/env_vars.json"
  raise "#{filename} is not a file" unless File.file? filename
  env_vars = JSON.parse File.read(filename)
  env_vars.each { |k, v| ENV[k] = v }
end

def job_info sample = nil
  header "Using Ruby - #{RUBY_VERSION}"
  header_2 "Job Type: #{ENV['JOB_TYPE']}"
  header_2 "Sample: #{sample}"
  puts ""
end

def run_tests acceptance: false, local: false
  failed = false
  failed = true if run "bundle exec rubocop"
  Dir.chdir "sessions" do
    Bundler.with_clean_env do
      job_info "sessions"
      failed = true if run "bundle update"
      load_env_vars unless local
      failed = true if run "bundle exec rake test"
      if acceptance
        failed = true if run "bundle exec rake acceptance", 1800
      end
    end
  end
  exit failed ? 1 : 0 unless acceptance
  Dir.chdir "bookshelf" do
    Bundler.with_clean_env do
      job_info "bookshelf"
      failed = true if run "wget -q https://storage.googleapis.com/gcd/tools/cloud-datastore-emulator-1.1.1.zip -O cloud-datastore-emulator.zip"
      failed = true if run "unzip -o cloud-datastore-emulator.zip"

      failed = true if run "cloud-datastore-emulator/cloud_datastore_emulator create gcd-test-dataset-directory"
      failed = true if run "cloud-datastore-emulator/cloud_datastore_emulator start --testing ./gcd-test-dataset-directory/ &"

      failed = true if run "RAILS_ENV=test bundle exec rake --rakefile=Rakefile assets:precompile"
      failed = true if run "bundle update"
      load_env_vars unless local
      failed = true if run "bundle exec rspec"
    end
  end
  exit failed ? 1 : 0
end

def run command, timeout = 0
  if timeout.positive?
    run_command_with_timeout command, timeout
  else
    run_command command
  end
end

def run_command command
  out, err, st = Open3.capture3 command
  puts out
  if st.to_i != 0
    puts err
    return true
  end
  false
end

def run_command_with_timeout command, timeout
  Timeout.timeout timeout do
    return run_command command
  end
rescue Timeout::Error
  header_2 "TIMEOUT - #{timeout / 60} minute limit exceeded."
  true
end
