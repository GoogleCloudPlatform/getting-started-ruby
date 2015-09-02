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

### Dependencies

To run the Hello World app, first ensure that you have Ruby 1.9.3 or newer.
Ruby 2.0 and above is recommended.

For information on installing Ruby, view [Installing Ruby][] on the [Ruby website][].

If you are using a system version of ruby, you will need to use `sudo` to install gems.

To install gems locally for your user, add the following to your `~/.bashrc` or `~/.bash_profile`:

    export GEM_HOME="$HOME/.gems"
    export GEM_PATH="$HOME/.gems"
    export PATH="$GEM_PATH/bin:$PATH"

Or gems can be installed using the [`--user-install` flag][user-install].

### Run

To run the application, first install dependencies:

    $ bundle install

And then run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ bundle exec rspec

### To deploy to App Engine Managed VMs

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
[Installing Ruby]: https://www.ruby-lang.org/en/documentation/installation/
[Ruby website]: https://www.ruby-lang.org
[user-install]: http://guides.rubygems.org/faqs/#user-install
[runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
