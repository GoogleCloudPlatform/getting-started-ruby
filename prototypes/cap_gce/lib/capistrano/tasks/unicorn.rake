Rake::Task["unicorn:start"].clear
Rake::Task["unicorn:stop"].clear
Rake::Task["unicorn:restart"].clear


namespace :unicorn do

  %w[start stop restart].each do |command|
    desc "#{command} unicorn sudo"
    task command do
      on roles :app do
        sudo :service, fetch(:unicorn_service), command
      end
    end
  end

end
