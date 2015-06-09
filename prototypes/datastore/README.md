# Using Datastore from Ruby

Simple sample of running a Ruby application on [App Engine Managed VMs][] 
that uses Datastore in some way.

Uses the the [`google/ruby-runtime`][] Docker image with no customization.

## Run locally

 - Setup a project in the [Google Developers Console][]
 - Enable the [Datastore API][]
 - Create a new [Service Account][] and download a JSON key
 - Move the JSON key to this project directory as `key.json`

    $ cp datastore.example.yml datastore.yml

Configure your production and development Datastore project configuration in `datastore.yml`.

    $ bundle
    $ bundle exec ruby app.rb

## Run test

Tests require [downloading][gcd_dl] and running the Datastore [Local Development Server][gcd].

Configure your test environment in `datastore.yml` with the `host` and `dataset_id` of your gcd dataset.

To create a dataset, run `gcd.sh create <dataset ID>`

    $ gcd.sh start --testing <your dataset directory>
    $ bundle
    $ rspec test.rb

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [gcloud][] for Datastore
 - Using [sinatra][] for making the web application
 - Using [slim][] for HTML templating

[Google Developers Console]: https://console.developers.google.com
[Datastore API]: https://console.developers.google.com/project/_/apiui/apiview/datastore/overview
[Service Account]: https://console.developers.google.com/project/_/apiui/credential
[gcd]: https://cloud.google.com/datastore/docs/tools/devserver
[gcd_dl]: https://cloud.google.com/datastore/docs/downloads#tools
[Datastore]: https://cloud.google.com/datastore/docs/concepts/overview
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[gcloud]: https://googlecloudplatform.github.io/gcloud-ruby/ 
[sinatra]: http://www.sinatrarb.com/
[slim]: http://slim-lang.com/
