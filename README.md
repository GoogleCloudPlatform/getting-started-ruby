# Getting Started Ruby

Checkout branches to view particular steps of this sample application.

 - [`1-hello-world`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/1-hello-world)
 - [`2-cloud-datastore`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/2-cloud-datastore)
 - [`2-cloud-sql`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/2-cloud-sql)
 - [`2-postgresql`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/2-postgresql)
 - [`3-cloud-storage`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/3-cloud-storage)
 - [`4-auth`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/4-auth)
 - [`5-logging`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/5-logging)
 - [`6-task-queueing`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/6-task-queueing)
 - [`7-compute-engine`](https://github.com/GoogleCloudPlatform/getting-started-ruby/tree/7-compute-engine)

[Ruby on Rails][ror] web application on [Google Managed VMs][mvms].

### Run

To run the application, first install dependencies:

    $ bundle install

And then run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ bundle exec rspec

### To deploy to App Engine Managed VMs

Install the [Google Cloud SDK](https://cloud.google.com/sdk):

    $ curl https://sdk.cloud.google.com | bash

And then deploy the application:

    $ gcloud preview app deploy app.yaml --set-default

The application Dockerfile uses the [`google/ruby-runtime`][runtime] Docker image
which supports running any Ruby web application.

The `ruby-runtime` image requires that your application directory contain the following:

 - `Gemfile` file declaring application dependencies
 - `config.ru` rackup file defining your web application

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE](LICENSE)

[ror]: http://rubyonrails.org/
[mvms]: https://cloud.google.com/appengine/docs/managed-vms/
[runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
