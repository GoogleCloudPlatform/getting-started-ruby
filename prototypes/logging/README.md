# Custom Logging Sample

Simple samples that log.  Logs are visible in the Developers Console under [Monitoring > Logs][logs].

[Custom Managed VM Logs][] are written to any `.log` file under `/var/log/app_engine/custom_logs`.

Uses the [`google/ruby-runtime`][] Docker image with no customization.

Two examples are provided:

 - Sinatra example using [`Logger`][logger] directly
 - Rails example using [`Rails.logger`][rails.logger]

## Run locally

    $ bundle
    $ bundle exec rails s

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

[logger]: http://ruby-doc.org/stdlib-2.2.2/libdoc/logger/rdoc/Logger.html
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[logs]: https://console.developers.google.com/project/_/logs
[Custom Managed VM Logs]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#logging
[rails.logger]: http://guides.rubyonrails.org/debugging_rails_applications.html#the-logger
