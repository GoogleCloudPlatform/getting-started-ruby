# Rails on Managed VMs

Simple Hello World [Rails][] application that runs on [App Engine Managed VMs][] 

Base Rails application resulting from `rails new` that runs on Managed VMs.

Uses the the [`google/ruby-runtime`][] Docker image with no customization.

Added App Engine [health check requests][] and made the root route render something.

## Run locally

    $ bundle
    $ rails s

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

[Rails]: http://rubyonrails.org/
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[health check requests]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#health_check_requests
