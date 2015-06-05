# Ruby/Rack Hello World on Managed VMs

Simple sample of running a Hello World [rack][] application on [App Engine Managed VMs][] 
using the [`google/ruby-runtime`][] Docker image with no customization.

App Engine [health check requests][] implicitly work because this application always
returns `200` with a non-empty response body.

## Run locally

    $ bundle
    $ bundle exec rackup

## Run test

    $ bundle
    $ bundle exec rspec test.rb

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [rack][] for making the web application
 - Using [rspec][] testing framework
 - Using [rack-test][] Rack application testing library

[rack]: http://rack.github.io/
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[health check requests]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#health_check_requests
[rspec]: http://rspec.info/
[rack-test]: https://github.com/brynary/rack-test
