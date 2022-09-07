# Getting Started Ruby

[![Travis Build Status](https://travis-ci.org/GoogleCloudPlatform/getting-started-ruby.svg)](https://travis-ci.org/GoogleCloudPlatform/getting-started-ruby)

Checkout folders to view particular steps of this sample application.

 - [`bookshelf/`](bookshelf/)
     - Code for the [Getting started with Ruby][getting-started] tutorial.

[Ruby on Rails][ror] web application on [Google App Engine][gae].

### Google Cloud Samples

To browse ready to use code samples check [Google Cloud Samples](https://cloud.google.com/docs/samples?l=ruby).

### Run

To run the application, first install dependencies:

    $ bundle install

And then run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ bundle exec rspec

### To deploy to App Engine

Install the [gcloud CLI](https://cloud.google.com/cli): https://cloud.google.com/sdk/docs/install-sdk

And then deploy the application:

    $ gcloud app deploy

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE](LICENSE)

[getting-started]: http://cloud.google.com/ruby/getting-started/
[ror]: http://rubyonrails.org/
[gae]: http://cloud.google.com/appengine/docs/standard/ruby
