# Calling Google Books API from Ruby

Simple sample of running a Ruby application on [App Engine Managed VMs][] 
that uses the [Google Books API][reference] in some way.

Uses a custom Dockerfile based on [`google/ruby`][] image to install `libmysqlclient-dev`.

Uses the the [`google/ruby-runtime`][] Docker image with no customization.

## Run locally

 - Setup a project in the [Google Developers Console][]
 - Enable the [Google Books API][]
 - Create a new [Service Account][] and download a JSON key
 - Move the JSON key to this project directory as `key.json`

    $ bundle
    $ bundle exec rackup

## Run test

    $ bundle
    $ rspec test.rb

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [google-api-client][] for calling Books API
 - Using [sinatra][] for making the web application
 - Using [slim][] for HTML templating

[Google Developers Console]: https://console.developers.google.com
[Datastore API]: https://console.developers.google.com/project/_/apiui/apiview/datastore/overview
[Service Account]: https://console.developers.google.com/project/_/apiui/credential
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[reference]: https://developers.google.com/books/docs/v1/reference/
[Google Books API]: https://console.developers.google.com/project/_/apiui/apiview/books/overview
[google-api-client]: https://github.com/google/google-api-ruby-client
[sinatra]: http://www.sinatrarb.com/
[slim]: http://slim-lang.com/
