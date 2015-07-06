# Ruby Getting Started

## Hello, World!

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
    $ rspec spec/

### To deploy to App Engine Managed VMs

    $ gcloud preview app deploy app.yaml --set-default

The application Dockerfile uses the [`google/ruby-runtime`][runtime] Docker image
which supports running any Ruby web application.

The `ruby-runtime` image requires that your application directory contain the following:

 - `Gemfile` file declaring application dependencies
 - `config.ru` rackup file defining your web application

[ror]: http://rubyonrails.org/
[mvms]: https://cloud.google.com/appengine/docs/managed-vms/
[Installing Ruby]: https://www.ruby-lang.org/en/documentation/installation/
[Ruby website]: https://www.ruby-lang.org
[user-install]: http://guides.rubygems.org/faqs/#user-install
[runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
