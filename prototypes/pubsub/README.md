# Pub/Sub Example

Simple sample application that uses [Pub/Sub][] via [gcloud][] to:

 - create/delete topics
 - create/delete subscriptions
 - publish messages to topics
 - pull messages from subscriptions
 - create push subscriptions (messages can be seen in [Logs Viewer][])

Uses the the [`google/ruby-runtime`][] Docker image with no customization.

## Run Locally

 - Setup a project in the [Google Developers Console][]
 - Enable the [Pub/Sub API][]
 - Create a new [Service Account][] and download a JSON key
 - Move the JSON key to this project directory as `key.json`

Configure your production and development Datastore project configuration in `pubsub.yml`.

    $ cp pubsub.example.yml pubsub.yml

To start the web application:

    $ bundle
    $ bundle exec rackup

## Run tests

    $ bundle exec rspec spec/

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [gcloud][] for Pub/Sub
 - Using [sinatra][] for making the web application
 - Using [slim][] for HTML templating
 - Using [rspec][] testing framework
 - Using [Capybara][] for browser-like testing API
 - Using [rack-test][] for testing routes

[Pub/Sub]: https://cloud.google.com/pubsub/
[gcloud]: http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Pubsub.html
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[Logs Viewer]: https://console.developers.google.com/project/_/logs
[Google Developers Console]: https://console.developers.google.com
[Pub/Sub API]: https://console.developers.google.com/project/_/apiui/apiview/pubsub/overview
[Service Account]: https://console.developers.google.com/project/_/apiui/credential
[sinatra]: http://www.sinatrarb.com/
[slim]: http://slim-lang.com/
[rspec]: http://rspec.info/
[Capybara]: https://github.com/brynary/rack-test
[rack-test]: https://github.com/brynary/rack-test
