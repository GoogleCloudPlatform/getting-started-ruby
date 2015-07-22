# Sinatra on Managed VMs

Simple sample of a [Sinatra][] app that runs on [App Engine Managed VMs][] .

Used the [`google/ruby-runtime`][] Docker image.

## Run locally

    $ bundle
    $ bundle exec rackup

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

[Sinatra]: http://www.sinatrarb.com/
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
