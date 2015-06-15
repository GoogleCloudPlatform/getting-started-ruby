# Custom Logging Sample

Simple sample that logs and the logs show up in the Developers Console
under [Monitoring > Logs][logs].

Uses the [`google/ruby-runtime`][] Docker image with no customization.

App Engine [health check requests][] implicitly work because this application always
returns `200` with a non-empty response body.

## Run locally

    $ bundle
    $ bundle exec rackup

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [rack][] for making the web application
 - Ruby's builtin [logging][] library

[rack]: http://rack.github.io/
[logging]: http://ruby-doc.org/stdlib-2.2.2/libdoc/logger/rdoc/Logger.html
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[health check requests]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#health_check_requests
[logs]: https://console.developers.google.com/project/_/logs
