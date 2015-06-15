# Vivid has made some changes to "service X start" and the upstream
# capistrano-unicorn-nginx gem does not work out of the box.

%w[start stop restart].each do |command|
  Rake::Task["unicorn:#{command}"].clear
end

namespace :unicorn do

  %w[start stop].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles :app do
        execute ["", "etc", "init.d", fetch(:unicorn_service)].join("/"), command
      end
    end
  end

  desc "restart unicorn"
  task "restart" do
    on roles :app do
      execute ["", "etc", "init.d", fetch(:unicorn_service)].join("/"), "stop"
      sleep 10
      execute ["", "etc", "init.d", fetch(:unicorn_service)].join("/"), "start"
    end
  end

end
